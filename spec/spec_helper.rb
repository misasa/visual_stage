require 'visual_stage'
Dir.glob("spec/steps/**/*steps.rb") { |f| load f, true }

def deleteall(delthem)
	if FileTest.directory?(delthem) then
		Dir.foreach( delthem ) do |file|
			next if /^\.+$/ =~ file
			deleteall(delthem.sub(/\/+$/,"") + "/" + file)
		end
		Dir.rmdir(delthem) rescue ""
	else
		File.delete(delthem)
	end
end

def setup_file(destfile)
	src_dir = File.expand_path('../fixtures/files',__FILE__)
	filename = File.basename(destfile)
	dest_dir = File.dirname(destfile)
	dest = File.join(dest_dir, filename)
	src = File.join(src_dir, filename)
	FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)
	FileUtils.copy(src, dest)
end

def setup_data(destdir)
	src_dir = File.expand_path('../fixtures/data',__FILE__)
	basename = File.basename(destdir)
	dest_dir = File.dirname(destdir)
	src = File.join(src_dir, basename)
	FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)
	FileUtils.cp_r(src, dest_dir)
end
