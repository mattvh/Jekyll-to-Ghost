# Jekyll-to-Ghost
#
# This Jekyll plugin exports your Markdown posts into a format that can be easily imported by Ghost.
# http://ghost.org
#
# Author: Rose Lin (updated based on Matt Harzewski's work)
# Copyright: Copyright 2013 Matt Harzewski
# License: GPLv2 or later
# Version: 1.0.1


require 'json'


module Jekyll



	class GhostPage < StaticFile

		def initialize(site, base, dir, name, contents)
			@site = site
			@base = base
			@dir  = dir
			@name = name
			@contents = contents
		end

		def write(dest)
			File.open(File.join(@site.config['destination'], 'ghost_export.json'), 'w') do |f|
				f.write(@contents.to_json.to_s)
			end
			true
		end

	end



	class JsonFileGenerator < Generator


		safe true


		def initialize(site)
			super
			@tags = []
			@postTagMap = Hash.new
		end


		def generate(site)

			converter = site.find_converter_instance(Jekyll::Converters::Markdown)
			ex_posts = []
			id = 0

			site.posts.docs.each do |post|

				timestamp = post.date.to_i * 1000
                
                author_id = 1
                if !((post.data['author']).nil?)
                    author_id = post.data['author']
                end
                
				ex_post = {
					"id" => id,
					"title" => post.data['title'],
					"slug" => post.data['slug'],
					#"markdown" => post.content,
					"html" => converter.convert(post.content),
                    "feature_image" => nil,
					"featured" => 0,
					"page" => 0,
					"status" => "published",
                    "published_at" => timestamp,
                    "published_by" => 1,
                    "meta_title" => nil,
        			"meta_description" => nil,
                    "author_id" => author_id,
                    "created_at" => timestamp,
        			"created_by" => 1,
        			"updated_at" => timestamp,
        			"updated_by" => 1
				}

				ex_posts.push(ex_post)

				self.process_tags(id, post.data['tags'], post.data['categories'])
				id += 1
			end

			export_object = {
				"meta" => {
					"exported_on" => Time.now.to_i * 1000,
					"version" => "2.14.0"
				},
				"data" => {
					"posts" => ex_posts,
					"tags" => self.tag_objects,
					"posts_tags" => self.posts_tag_objects,
                    "users" => self.author_objects(site)
                    # TODO: add roles_users
				}
			}

			site.static_files << GhostPage.new(site, site.source, site.config['destination'], 'ghost_export.json', export_object)

		end


		def process_tags(postId, tags, categories)
			unique_tags = tags | categories
			unique_tags = unique_tags.map do |t|
				t = t.chomp(",")
				t = t.downcase
			end
			@tags = unique_tags | @tags

			@postTagMap[postId] = unique_tags
		end


		def tag_objects
			tag_array = []
			@tags.each do |tag|
				tag_array.push({
					"id" => tag_array.size,
					"name" => tag,
					"slug" => tag.downcase,
					"description" => ""
				})
			end
			return tag_array
		end

		def posts_tag_objects
			posts_tag_array = []
			@postTagMap.each do |post, tags|
				tags.each do |tag|
					posts_tag_array.push({
										"id" => (posts_tag_array.size + 1),
										"post_id" => post,
										"tag_id" => @tags.index(tag)
										})
				end
			end
			return posts_tag_array
		end
        
        def author_objects(site)
			author_array = []
            
            # check if the site has any author information
            is_author_set = false
            if site.data.key?('authors')
                is_author_set = true
            end
            
            if is_author_set then
                all_users = site.data['authors'].keys
                
                for u in all_users do
                    author = site.data['authors'][u]
                    
                    ex_author = {
                        "id" => u,
                        "name" => author['name'],
                        "slug" => nil,
                        "email" => author['email'] ? author['email'] : nil,
                        "profile_image" => author['profile_image'] ? author['profile_image'] : nil,
                        "cover_image" => author['cover_image'] ? author['cover_image'] : nil,
                        "bio" => author['bio'] ? author['bio'] : nil,
                        "website" => author['website'] ? author['website'] : nil,
                        "location" => author['location'] ? author['location'] : nil,
                        "accessibility" => author['accessibility'] ? author['accessibility'] : nil,
                        "meta_title" => author['meta_title'] ? author['meta_title'] : nil,
                        "meta_description" => author['meta_description'] ? author['meta_description'] : nil,
                        "created_at" => Time.now.to_i * 1000,
                        "created_by" => 1,
                        "updated_at" => Time.now.to_i * 1000,
                        "updated_by" => 1
                    }

                    author_array.push(ex_author)

                end
            end
            
            # handle cases when there is no author information provided from the _data folder
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
                    
            author_array.push(default_author)
            
			return author_array
		end

	end



end
