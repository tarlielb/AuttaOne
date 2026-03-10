require 'fileutils'

directories = ['app/views', 'app/javascript', 'config/locales', 'app/mailers']
search_word = 'Chatwoot'
search_word_lower = 'chatwoot'
replacement_word = 'Autta.ONE'

directories.each do |dir|
  Dir.glob("#{dir}/**/*").each do |path|
    next if File.directory?(path)
    next unless ['.rb', '.yml', '.js', '.vue', '.erb', '.liquid', '.html'].include?(File.extname(path))

    begin
      content = File.read(path)
      if content.include?(search_word) || content.include?(search_word_lower)
        # Avoid replacing chatwoot inside URLs or variable names if possible, but for locales and UI text we want to replace it.
        # Actually, replacing all text occurrences of "Chatwoot" (capitalized) is usually safe for UI components.
        # Let's be careful with lowercase "chatwoot" as it might be used in package names or URLs.
        new_content = content.gsub(/Chatwoot/i) do |match|
          # If it's part of a URL like "chatwoot.com" or a variable like "window.$chatwoot", let's be careful.
          # For a simple whitelabel, we replace capitalized "Chatwoot" with "Autta.ONE"
          # and leave "chatwoot" lowercase mainly alone, unless it's standalone.
          if match == 'Chatwoot'
            'Autta.ONE'
          elsif match == 'CHATWOOT'
            'AUTTA.ONE'
          else
            match # keep original (e.g., chatwoot)
          end
        end

        if new_content != content
          File.write(path, new_content)
          puts "Updated #{path}"
        end
      end
    rescue => e
      puts "Error processing #{path}: #{e.message}"
    end
  end
end
puts "Brand replacement script finished."
