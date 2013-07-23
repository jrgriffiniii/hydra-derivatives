module Hydra
  module Derivatives
    class Image < Processor
      def process
        directive.each do |name, size| 
          create_resized_image(output_datastream_id(name), size, new_mime_type)
        end
      end


      protected

      def new_mime_type
        'image/png'
      end


      def create_resized_image(output_dsid, long_edge_size, mime_type, quality=nil)
        create_image(output_dsid, mime_type, quality) do |xfrm|
          xfrm.change_geometry!("#{long_edge_size}x#{long_edge_size}") do |cols, rows, img|
           img.resize!(cols, rows)
          end
        end
      end

      def create_image(dsid, mime_type, quality=nil)
        xfrm = load_image_transformer
        yield(xfrm) if block_given?
        #out = output_datastream
        output_datastream(dsid).content = if quality
          xfrm.to_blob { self.quality = quality }
        else
          xfrm.to_blob
        end
        output_datastream(dsid).mimeType = mime_type
      end

      # Override this method if you want a different transformer, or need to load the 
      # raw image from a different source (e.g.  external datastream)
      def load_image_transformer
        Magick::ImageList.new.tap do |xformer|
          xformer.from_blob(source_datastream.content)
        end
      end
    end
  end
end
