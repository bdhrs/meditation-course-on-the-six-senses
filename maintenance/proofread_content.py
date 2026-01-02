import re
import time
from pathlib import Path
from openrouter import OpenRouter
from maintenance.config_utils import get_api_key


class Proofreader:
    def __init__(self, model="xiaomi/mimo-v2-flash:free", delay=1.0):
        self.api_key = get_api_key()
        if not self.api_key:
            raise KeyError("API_KEY not found in config.ini")
        self.model = model
        self.delay = delay

    def call_llm(self, text, model_name=None, mode="prose"):
        """
        Calls the LLM via OpenRouter to proofread the text.
        """
        if not text.strip():
            return "NO_ERRORS"

        # Respect rate limits
        if self.delay > 0:
            time.sleep(self.delay)

        target_model = model_name or self.model

        role_description = (
            "You are a strict proofreader for a meditation course. "
            "Your goal is to identify and correct serious spelling and grammar errors only. "
            "Use British English spelling consistently (e.g., 'unskilful', 'colour', 'centre'). "
            "Do NOT change the tone, style, or vocabulary, unless something is wrong. "
            "Keep the existing voice intact. "
            "Ignore Pāḷi quotes (blockquotes that are clearly in Pāḷi). "
            "Ensure all Pāḷi terms (like *dukkha*, *anicca*, *anatta*, *vedanā*, *saṅkhāra*, *nibbāna*, *kamma*, *dhamma*, *saṅgha*, *buddha*, *sati*, *samādhi*, *paññā*, *sutta*, etc.) within English prose are correctly italicized. "
        )

        if mode == "scripts":
            role_description += "The provided text is a script for an audio recording. "
        else:
            role_description += "The provided text is prose from a course book. "

        max_retries = 3
        for attempt in range(max_retries):
            try:
                with OpenRouter(api_key=self.api_key) as client:
                    response = client.chat.send(
                        model=target_model,
                        messages=[
                            {
                                "role": "system",
                                "content": (
                                    f"{role_description}\n\n"
                                    "Formatting Instructions:\n"
                                    "1. If you find an error or missing italics, respond ONLY with pairs of:\n"
                                    "x <short snippet of original text containing the error>\n"
                                    "+ <corrected snippet>\n\n"
                                    "2. Use the shortest possible snippet that provides enough context to identify the location (usually 5-10 words).\n"
                                    "3. Do NOT add quotation marks around the snippets.\n"
                                    "4. Separate multiple suggestions with a blank line.\n"
                                    "5. If NO ERRORS are found in the provided text, respond with EXACTLY 'NO_ERRORS'.\n"
                                    "6. Do NOT provide any preamble, commentary, or the original text unless it has an error."
                                ),
                            },
                            {
                                "role": "user",
                                "content": f"Proofread the following text:\n\n{text}",
                            },
                        ],
                    )
                    return response.choices[0].message.content
            except Exception as e:
                print(f"    ! Error on attempt {attempt + 1} with {target_model}: {e}")
                if attempt < max_retries - 1:
                    time.sleep(2 * (attempt + 1))  # Exponential backoff
                else:
                    return "NO_ERRORS"
        return "NO_ERRORS"

    def extract_segments(self, content):
        """
        Legacy method for testing support.
        """
        transcripts = re.findall(r"%%(.*?)%%", content, flags=re.DOTALL)
        content_no_transcripts = re.sub(r"%%.*?%%", "", content, flags=re.DOTALL)
        content_no_code = re.sub(
            r"```.*?```", "", content_no_transcripts, flags=re.DOTALL
        )
        segments = []
        lines = content_no_code.split("\n")
        current_segment = []
        for line in lines:
            stripped = line.strip()
            if stripped.startswith(">"):
                if current_segment:
                    segments.append("\n".join(current_segment).strip())
                    current_segment = []
                continue
            if stripped.startswith("#"):
                if current_segment:
                    segments.append("\n".join(current_segment).strip())
                    current_segment = []
                segments.append(stripped)
                continue
            if not stripped:
                if current_segment:
                    segments.append("\n".join(current_segment).strip())
                    current_segment = []
                continue
            current_segment.append(line)
        if current_segment:
            segments.append("\n".join(current_segment).strip())
        for t in transcripts:
            if t.strip():
                segments.append(t.strip())
        return [s for s in segments if s]

    def filter_suggestions(self, suggestion_text):
        """
        Parses the LLM response and only returns pairs where x and + are different.
        """
        if (
            not suggestion_text
            or "x " not in suggestion_text
            or "+ " not in suggestion_text
        ):
            return None

        pattern = r"x (.*?)\n\+ (.*?)(?=\n\nx |\n\Z|$)"
        pairs = re.findall(pattern, suggestion_text, re.DOTALL)

        valid_pairs = []
        for original, suggested in pairs:
            if original.strip() != suggested.strip():
                valid_pairs.append(f"x {original.strip()}\n+ {suggested.strip()}")

        if valid_pairs:
            return "\n\n".join(valid_pairs)
        return None

    def proofread_file(self, file_path, report_file, models, mode="prose"):
        """
        Proofreads a single file with multiple models and writes suggestions to the report_file.
        """
        content = file_path.read_text(encoding="utf-8")

        if mode == "prose":
            text_to_proof = re.sub(r"%%.*?%%", "", content, flags=re.DOTALL)
        else:
            transcripts = re.findall(r"%%(.*?)%%", content, flags=re.DOTALL)
            text_to_proof = "\n\n".join([t.strip() for t in transcripts if t.strip()])

        if not text_to_proof.strip():
            return

        file_header_written = False

        for model_name in models:
            print(f"    - Running {model_name}...", flush=True)
            raw_suggestion = self.call_llm(
                text_to_proof, model_name=model_name, mode=mode
            ).strip()

            if "NO_ERRORS" in raw_suggestion and len(raw_suggestion) < 20:
                continue

            suggestion = self.filter_suggestions(raw_suggestion)

            if suggestion:
                if not file_header_written:
                    report_file.write(f"### {file_path.name}\n\n")
                    file_header_written = True

                report_file.write(f"#### Model: {model_name}\n")
                report_file.write(suggestion + "\n\n")
                report_file.flush()
                print(f"    - Suggestions found in {file_path.name} by {model_name}")


def main():
    print("Starting Automated AI Proofreading (Two-Stage Mode)")

    try:
        pr = Proofreader()
    except Exception as e:
        print(f"Error initializing Proofreader: {e}")
        return

    source_dir = Path("source")
    report_path = Path("maintenance/proofread_report.txt")

    models = ["xiaomi/mimo-v2-flash:free", "mistralai/devstral-2512:free"]

    def natural_sort_key(path):
        return [
            int(c) if c.isdigit() else c.lower() for c in re.split(r"(\d+)", path.name)
        ]

    md_files = sorted(list(source_dir.glob("*.md")), key=natural_sort_key)
    skip_files = {"9.2. Sutta References.md"}

    with open(report_path, "w", encoding="utf-8") as report_file:
        report_file.write("# PROOFREADING REPORT\n\n")

        # Stage 1: Prose
        print("\n--- STAGE 1: PROSE ---")
        report_file.write("## STAGE 1: PROSE (Excluding scripts)\n\n")
        total_files = len(md_files)
        for i, md_file in enumerate(md_files, 1):
            if md_file.name.startswith(("X", ".")) or md_file.name in skip_files:
                continue
            print(f"[{i}/{total_files}] Prose: {md_file.name}...", flush=True)
            pr.proofread_file(md_file, report_file, models, mode="prose")

        # Stage 2: Scripts
        print("\n--- STAGE 2: SCRIPTS ---")
        report_file.write(
            "\n---\n\n## STAGE 2: SCRIPTS (Only text inside %% blocks)\n\n"
        )
        for i, md_file in enumerate(md_files, 1):
            if md_file.name.startswith(("X", ".")) or md_file.name in skip_files:
                continue
            print(f"[{i}/{total_files}] Scripts: {md_file.name}...", flush=True)
            pr.proofread_file(md_file, report_file, models, mode="scripts")

    print(f"\nProofreading complete. Report generated at {report_path}")


if __name__ == "__main__":
    main()
