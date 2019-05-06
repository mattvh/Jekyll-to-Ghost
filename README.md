Jekyll-to-Ghost Exporter (Updated version)
========================

*Note as of 5/3/2019*: This is an updated version of what [mattvh](https://github.com/mattvh/Jekyll-to-Ghost) posted. I've integrated some changes so that it can easily export a Jekyll site to Ghost 2.14.0.

Want to export your Markdown posts from [Jekyll](http://jekyllrb.com) to a format that can be easily imported into [Ghost?](http://ghost.org) This plugin will help you do that, though there are some limitations. It doesn't handle static pages, and it doesn't do anything with images. You'll have to copy those over yourself and manually adjust any URL differences.

This was built by reverse-engineering the WordPress exporter [plugin](http://wordpress.org/plugins/ghost/) to match the JSON file it outputs.


Installation
------------

0. Clone the repo and drop the `jekylltoghost.rb` file into your Jekyll site's `_plugins` directory
1. Run `jekyll build`.
2. There should now be a `ghost_export.json` file in the `_site` directory.
3. Follow the Ghost guide [here](https://docs.ghost.org/api/migration/#converting-html) to convert the HTML block into **Mobiledoc** (this is what the new Ghost blog accepts).
    * Core command: `migrate json html /path/to/your/import.json` -> this line will generate a new JSON file with Mobiledoc entries added.
4. Download the JSON file, (optional) edit the `users` section, and import it through the Ghost Lab tab.

Right now the script is able to automatically extract authors information stored under the `_data` folder. **Please ensure that your xml/csv filename is "authors", otherwise the code needs to be changed so that the auto extraction function would work.** For posts that have no author information (or the site has NOT configured any author), the script will add a user named `default`. It is strongly encouraged that you change the default user information. 

Starting from line 193 of `jekylltoghost.rb` (or search `default_author`):

```
default_author = {
                "id" => 1,
                "name" => "default", # Change this to your name
                "slug" => nil, # Change this to your slug, or keep it nil. Ghost will automatically assign one if nil
                "email" => "example@test.com", # Change this to your email
                "profile_image" => nil, # Change this to your profile image url
                "cover_image" =>  nil, # Change this to your cover image url
                "bio" => nil, # Change this to your bio
                "website" => "https://ghost.org/", # Change this to your website
                "location" => nil, # Change this to your location
                "accessibility" => nil, # Change this to your accessibility
                "meta_title" => nil, # Change this to your meta title (optional)
                "meta_description" => nil, # Change this to your meta description (optional)
                "created_at" => Time.now.to_i * 1000,
                "created_by" => 1,
                "updated_at" => Time.now.to_i * 1000,
                "updated_by" => 1
            }
```

You can change the fields based on your need. It's encouraged to have the same `slug` if you have already created a Ghost user, so that Ghost can aggregate all posts together. You can find it under the admin page > Staff > click on the desired user to open up details > slug.

Questions
------------
Please submit a PR/issue or contact the original author of the script.

License
-------

This Jekyll plugin is licensed under the MIT license.
