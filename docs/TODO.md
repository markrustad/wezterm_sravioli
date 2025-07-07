# Current goals

Detail a roadmap for what specific tasks need to be accomplished.

## Launcher and SSH domain

- SSH entries are not in the launcher

## Backdrop doesn't survive picker coloscheme picker change

The good:

- The custom background of compoiste image files renders at WezTerm launch

- Persists through font style, font size, font line height change

The bad:

- The background picker does not change the background image

**FIXED** The background persists through font style, font size, font line height change via backdrop picker

- ~~The background dissapears when the coloscheme picker is run (and will not return until the next WezTerm launch)~~ (Fixed)

Relevant context:

- the original repo that implements this feature made a note in [wezterm-config/utils/backdrops.lua]("https://github.com/KevinSilvester/wezterm-config/blob/b78b3f3cce327ebd748b8973c072990e129c82e6/utils/backdrops.lua")

And this is initialized early in the main `wezterm.lua` file:

