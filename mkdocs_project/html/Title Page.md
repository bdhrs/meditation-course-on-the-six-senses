<div class="title-page-container">
  <div class="title-large">Meditation Course on the Six Senses</div>
</div>

<style>
.title-page-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 60vh;
    padding: 2rem;
}

.title-large {
    font-size: 4rem;
    font-weight: 700;
    text-align: center;
    line-height: 1.2;
    color: var(--md-primary-fg-color);
    margin: 0;
}

/* Ensure good contrast in both light and dark modes */
[data-md-color-scheme="default"] .title-large {
    color: var(--md-primary-fg-color);
}

[data-md-color-scheme="slate"] .title-large {
    color: var(--md-primary-fg-color);
}

@media screen and (max-width: 768px) {
    .title-large {
        font-size: 2.5rem;
    }
    
    .title-page-container {
        min-height: 50vh;
        padding: 1rem;
    }
}
</style>