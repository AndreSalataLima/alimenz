require "prawn"
require "prawn/measurement_extensions"
require "stringio"

class PdfMergeService
  def self.merge_files(uploaded_files)
    pdf = Prawn::Document.new(page_size: "A4", margin: 0)

    uploaded_files.each_with_index do |uploaded_file, index|
      pdf.start_new_page unless index.zero?
      image_path = uploaded_file.tempfile.path
      pdf.image(image_path, at: [0, pdf.bounds.top], width: pdf.bounds.width, height: pdf.bounds.height)
    end

    pdf_io = StringIO.new(pdf.render)
    pdf_io.rewind
    pdf_io
  end
end
