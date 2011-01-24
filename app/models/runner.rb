class Runner < Qt::Process
  def initialize(main)
    super
    
    @main_widget = main
    connect(SIGNAL(:readyReadStandardOutput), &method(:read_data))
  end

  def run(code = default_code, code_file_name = default_kid_code_location)
    save_kid_code(code, code_file_name)
    self.start("ruby #{code_file_name}")
  end

  def read_data
    @main_widget.append(self.readAllStandardOutput())
  end
  
  def save_kid_code(code, code_file_name)
    ensure_tmp_dir
    
    codeFile = Qt::File.new(code_file_name)
    if !codeFile.open(Qt::File::WriteOnly | Qt::File::Text)
        Qt::MessageBox.warning(self, tr("KidsRuby Problem"),
                               tr("Oh, uh! Cannot write file %s:\n%s" %
                               [ codeFile.fileName(), codeFile.errorString() ] ) )
        return
    end

    codeFile.write(build_code_from_fragment(code))
    codeFile.close()
  end
  
  def build_code_from_fragment(code)
    # todo: add any default requires for kid stuff here
    new_code = "require './lib/kidsruby_dialogs'\n"
    new_code << code
    new_code
  end
  
  def default_code
    'puts "No code entered"'
  end
  
  def default_kid_code_location
    "#{tmp_dir}/kidcode.rb"
  end
  
  def ensure_tmp_dir
    Dir.mkdir(tmp_dir) unless Dir.exists?(tmp_dir)
  end
  
  def tmp_dir
    "#{File.dirname(__FILE__)}/../../tmp"
  end
end
