module DocumentMacros
  def build_doc_with_name(name)
    doc = build(:document, filename: name)
    doc.sanitize_filename
    doc
  end
end
