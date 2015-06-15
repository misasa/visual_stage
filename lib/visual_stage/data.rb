require 'bindata'
module VisualStage
	class StructAttach < BinData::Record
		endian :little
		#790
		int32 :no # 4 byte
		string :name, :trim_padding => true, :length => 21 # 20 byte
	#	string :pad2, :length => 1 #1 byte
		string :file, :trim_padding => true, :length => 21 # 20 byte
		int32 :attach_class #4 byte
		double :x_locate, :onlyif => :image_file?  # 8 byte
		double :y_locate, :onlyif => :image_file? # 8 byte
		int32 :imag, :onlyif => :image_file? # 4 byte
#		string :skip1, :length => 16, :onlyif => :image_file?
		skip :length => 16, :onlyif => :image_file?
		double :x_center, :onlyif => :image_file? # 8 byte
		double :x_size, :onlyif => :image_file? # 8 byte
		# 102 bytes
#		string :skip2, :length => 24, :onlyif => :image_file?
		skip :length => 24, :onlyif => :image_file?
		double :y_center, :onlyif => :image_file? # 8 byte
		double :y_size, :onlyif => :image_file? # 8 byte
#		string :residue, :length => 648, :onlyif => :image_file?
		skip :length => 648, :onlyif => :image_file?
		def image_file?
			attach_class.nonzero?
		end
	end

	class StructAddress < BinData::Record
		endian :little
		#20054
		int32 :no #4 byte
		int16 :address_class #2 byte
		skip :length => 2
#		int16 :pad1 #2 bite
		string :name, :trim_padding => true, :length => 21 #20 byte
	#	stringz :name, :maxlength => 21
	#	string :pad2, :length => 1 #1 byte
		double :x_locate # 8 byte
		double :y_locate # 8 byte
		string :data, :trim_padding => true, :length => 200 # 200 byte
		# 245 byte
#		string :residue, :length => 19805
		skip :length => 19805
		int32 :attach_count # 4 byte
		array :attachs, :initial_length => :attach_count do
			struct_attach :struct_attach
		end
	end

	class AddressDAT < BinData::Record 
		endian :little
		string :identifier, :length => 10
		int16 :release
		int32 :address_count
	    array :addresses, :initial_length => :address_count do
	      struct_address  :struct_address
	    end

	end
end