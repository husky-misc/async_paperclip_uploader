
module AsyncPaperclipUploader
  class Permanent
    def initialize(class_name, object_id, attribute, filepath)
      @object = Object::const_get(class_name).find_by_id(object_id)
      @attribute = attribute
      @filepath = filepath
    end

    def call
      @object.send("#{@attribute}=", file)
      if @object.save
        if block_given?
          yield
        end
        #clean
      end
    end

    private

    def file
      File.open(@filepath)
    end

    def clean
      File.delete(@filepath)
    end
  end
end
