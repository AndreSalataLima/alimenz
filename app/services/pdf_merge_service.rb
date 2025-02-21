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

    # Converter o PDF em um StringIO para ser compatível com ActiveStorage
    pdf_io = StringIO.new(pdf.render) # Gera o PDF em memória
    pdf_io.rewind # Rebobina para permitir leitura

    pdf_io # Retorna um objeto IO compatível com ActiveStorage
  end
end
