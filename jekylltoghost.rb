# Jekyll-to-Ghost
# 
# This Jekyll plugin exports your Markdown posts into a format that can be easily imported by Ghost.
# http://ghost.org
# 
# Author: Matt Harzewski
# Copyright: Copyright 2013 Matt Harzewski
# License: GPLv2 or later
# Version: 1.0.0


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
		end


		def generate(site)

			converter = site.getConverterImpl(Jekyll::Converters::Markdown)
			ex_posts = []

			site.posts.each do |post|
				ex_post = {
					"title" => post.title,
					"slug" => post.slug,
					"markdown" => self.rewrite_posturl(post.content),
					"html" => converter.convert(self.rewrite_posturl(post.content)),
					"image" => nil,
					"featured" => 0,
					"page" => 0,
					"status" => "published",
					"language" => "de_DE",
					"meta_title" => nil,
        			"meta_description" => nil,
        			"author_id" => 1,
        			"created_at" => post.date.to_i * 1000,
        			"created_by" => 1,
        			"updated_at" => post.date.to_i * 1000,
        			"updated_by" => 1,
        			"published_at" => post.date.to_i * 1000,
        			"published_by" => 1,
        			"tags" => self.process_tags(post.tags, post.categories)
				}

				ex_posts.push(ex_post)
				
			end

			export_object = {
				"meta" => {
					"exported_on" => Time.now.to_i,
					"version" => "000"
				},
				"data" => {
					"posts" => ex_posts,
					"tags" => self.tag_objects
				}
			}

			site.static_files << GhostPage.new(site, site.source, site.config['destination'], 'ghost_export.json', export_object)

		end


		def process_tags(tags, categories)
			unique_tags = tags | categories
			@tags = unique_tags | @tags
			post_tags = []
			unique_tags.each do |t|
				post_tags.push({
					"name" => t
				})
			end
			return post_tags
		end


		def tag_objects
			tag_array = []
			@tags.each do |tag|
				tag_array.push({
					"id" => (tag_array.size + 1),
					"name" => tag,
					"slug" => tag.downcase,
					"description" => ""
				})
			end
			return tag_array
		end

		def rewrite_posturl(content)
			regex = /{%\s*post_url\s*(\d{4})-(\d{2})-(\d{2})-(.+?)\s*%}/
			return content.gsub(regex, '/\4/')
		end


	end



end
