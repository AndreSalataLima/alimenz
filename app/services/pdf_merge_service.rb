require "prawn"
require "combine_pdf"
require "stringio"

class PdfMergeService
  def self.merge_files(uploaded_files)
    final_pdf = CombinePDF.new

    uploaded_files.each do |uploaded_file|
      if uploaded_file.content_type == "application/pdf"
        pdf = CombinePDF.load(uploaded_file.tempfile.path)
        final_pdf << pdf
      elsif uploaded_file.content_type.start_with?("image/")
        # Cria um PDF com a imagem usando Prawn
        prawn_pdf = Prawn::Document.new(page_size: "A4", margin: 0)
        prawn_pdf.image uploaded_file.tempfile.path, at: [ 0, prawn_pdf.bounds.top ], width: prawn_pdf.bounds.width, height: prawn_pdf.bounds.height
        temp_io = StringIO.new(prawn_pdf.render)
        temp_io.rewind
        temp_combined = CombinePDF.parse(temp_io.read)
        final_pdf << temp_combined
      else
        raise "Unsupported file type: #{uploaded_file.content_type}"
      end
    end

    io = StringIO.new(final_pdf.to_pdf)
    io.rewind
    io
  end
end
