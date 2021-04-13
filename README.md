# scripts
just a bunch of scripts that I've made.

## link-i18n.sh script
It's a script that I use to link and unlink files from a source directory to a target directory.

Files under Target directory gets renamed to `filename~bak`, But only when said files are also
in the Source directory, this is basiclly making a back up for it.

I've created it so I can use it in other scripts or programs.
Like for example swtiching on and off Arabic localization files of a MediaWiki extension localaztion directory.

### Usage:
1. To link files from source to target:

    `sh link-i18n.sh -s SOURCE -t TARGET`
2. To unlink files from source to target, and also restore backup:

    `sh link-i18n.sh -u -t TARGET`
