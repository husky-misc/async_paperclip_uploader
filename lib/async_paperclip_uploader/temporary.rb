module AsyncPaperclipUploader
  class Temporary
    def initialize(object, attribute, uploaded_file)
      @object = object
      @attribute = attribute
      @uploaded_file = uploaded_file
    end

    def call
      if valid?
        upload
        run_permanent_upload_job
      end
    end

    def valid?
      valid_class_attr? && valid_attachment? 
    end

    def valid_class_attr?
      @object.respond_to?(@attribute.to_sym)
    end

    def valid_attachment?
      attachment = {
        :filename => @uploaded_file[:filename],
        :content_type => @uploaded_file[:type],
        :headers => @uploaded_file[:head],
        :tempfile => @uploaded_file[:tempfile]
      }
      @object.send("#{@attribute}=", ActionDispatch::Http::UploadedFile.new(attachment))
      @object.valid?
    end

    def self.base_path
      ENV["FILE_UPLOAD_STAGING_DIR"]
    end

    private
    def upload
      File.open(path, "wb") { |f| f.write(tempfile.read) }
    end

    def path
      extname = File.extname(@uploaded_file[:filename])
      name = "#{@attribute}-#{@object.id}#{extname}"
      File.join(self.class.base_path, name)
    end

    def tempfile
      @uploaded_file[:tempfile]
    end

    def run_permanent_upload_job
      job_class.perform_async(@object.id, @attribute, path)
    end

    def job_class
      name = "#{@object.class.name}#{base_job_class_name}"
      Object::const_get(name)
    end

    def base_job_class_name
      'UploadJob'
    end
  end
end