Jekyll-to-Ghost Exporter
========================

Want to export your Markdown posts from [Jekyll](http://jekyllrb.com) to a format that can be easily imported into [Ghost?](http://ghost.org) This plugin will help you do that, though there are some limitations. It doesn't handle static pages, and it doesn't do anything with images. You'll have to copy those over yourself and manually adjust any URL differences.

This was built by reverse-engineering the WordPress exporter [plugin](http://wordpress.org/plugins/ghost/) to match the JSON file it outputs.


Installation
------------

0. Clone the repo and drop the `jekylltoghost.rb` file into your Jekyll site's `_plugins` directory
1. Run `jekyll build`.
2. There should now be a `ghost_export.json` file in the `_site` directory, which you can copy and import into Ghost.


License
-------

This Jekyll plugin is licensed under the MIT license.
