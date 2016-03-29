AROUND_ROOT        = ENV["AROUND_ROOT"] || File.join(File.dirname(File.expand_path(__FILE__)))
AROUND_MRUBY_ROOT  = File.join(AROUND_ROOT, "mruby")
AROUND_GEMBOX_ROOT = File.join(AROUND_ROOT, "mrbgems")

MRuby::Build.new do |conf|
  conf.define_singleton_method(:host_target) { "" }
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # Use mrbgems
  # conf.gem 'examples/mrbgems/ruby_extension_example'
  # conf.gem 'examples/mrbgems/c_extension_example' do |g|
  #   g.cc.flags << '-g' # append cflags in this gem
  # end
  # conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
  # conf.gem :github => 'masuidrive/mrbgems-example', :branch => 'master'
  # conf.gem :git => 'git@github.com:masuidrive/mrbgems-example.git', :branch => 'master', :options => '-v'

  # include the default GEMs
  #conf.gembox 'default'
  
  conf.cc.defines << %w(SHA256_DIGEST_LENGTH=32 SHA512_DIGEST_LENGTH=64 MRB_STACK_EXTEND_DOUBLING)
  if RUBY_PLATFORM =~ /x86_64-linux/i
  elsif RUBY_PLATFORM =~ /linux/i
    conf.cc.flags << %w(-msse2)
    conf.linker.flags << %w(-msse2)
  end

  # Generate mirb command
  conf.gem :core => "mruby-bin-mirb"

  # Generate mruby command
  conf.gem :core => "mruby-bin-mruby"

  # Generate mruby-strip command
  conf.gem :core => "mruby-bin-strip"

  # C compiler settings
  conf.cc do |cc|
    cc.command = ENV['CC'] || 'gcc'
    cc.flags = [ENV['CFLAGS'] || %w(-std=gnu99 -D_POSIX_C_SOURCE=200112L -D_GNU_SOURCE)]
    # cc.include_paths = ["#{root}/include"]
  #   cc.defines = %w(DISABLE_GEMS)
  #   cc.option_include_path = '-I%s'
  #   cc.option_define = '-D%s'
  #   cc.compile_options = "%{flags} -MMD -o %{outfile} -c %{infile}"
  end

  # mrbc settings
  # conf.mrbc do |mrbc|
  #   mrbc.compile_options = "-g -B%{funcname} -o-" # The -g option is required for line numbers
  # end

  # Linker settings
  # conf.linker do |linker|
  #   linker.command = ENV['LD'] || 'gcc'
  #   linker.flags = [ENV['LDFLAGS'] || []]
  #   linker.flags_before_libraries = []
  #   linker.libraries = %w()
  #   linker.flags_after_libraries = []
  #   linker.library_paths = []
  #   linker.option_library = '-l%s'
  #   linker.option_library_path = '-L%s'
  #   linker.link_options = "%{flags} -o %{outfile} %{objs} %{libs}"
  # end

  # Archiver settings
  # conf.archiver do |archiver|
  #   archiver.command = ENV['AR'] || 'ar'
  #   archiver.archive_options = 'rs %{outfile} %{objs}'
  # end

  # Parser generator settings
  # conf.yacc do |yacc|
  #   yacc.command = ENV['YACC'] || 'bison'
  #   yacc.compile_options = '-o %{outfile} %{infile}'
  # end

  # gperf settings
  # conf.gperf do |gperf|
  #   gperf.command = 'gperf'
  #   gperf.compile_options = '-L ANSI-C -C -p -j1 -i 1 -g -o -t -N mrb_reserved_word -k"1,3,$" %{infile} > %{outfile}'
  # end

  # file extensions
  # conf.exts do |exts|
  #   exts.object = '.o'
  #   exts.executable = '' # '.exe' if Windows
  #   exts.library = '.a'
  # end

  # file separetor
  # conf.file_separator = '/'
end

# Define cross build settings
# MRuby::CrossBuild.new('device') do |conf|
#   toolchain :gcc

#   enable_debug

#   conf.cc.defines << %w(SHA256_DIGEST_LENGTH=32 SHA512_DIGEST_LENGTH=64 MRB_STACK_EXTEND_DOUBLING)

#   if RUBY_PLATFORM =~ /x86_64-linux/i
#   elsif RUBY_PLATFORM =~ /linux/i
#     conf.cc.flags << %w(-msse2)
#     conf.linker.flags << %w(-msse2)
#   end

#   conf.gembox File.join(AROUND_ROOT, "mrbgems", "around")
# end

# Define cross build settings
MRuby::CrossBuild.new('avixy3400') do |conf|
  toolchain :gcc

  toolchain_prefix = 'arm-linux-'
  path_to_toolchain = '/opt/toolchain/usr'

  GCC_COMMON_CFLAGS  = %W(-O0 -g3 -Wall -c -fmessage-length=0 -std=gnu99 -D_POSIX_C_SOURCE=200112L -D_GNU_SOURCE -DAVIXY_DEVICE)
  GCC_COMMON_LDFLAGS = %W(-pthread -std=gnu99)
  ARCH_CFLAGS  = %W(-DAVX_MODEL=4000)
  ARCH_LDFLAGS = %W(-DAVX_MODEL=4000)
  #Remember to add -s to omit symbol information.

  AVIXY_CC = path_to_toolchain + '/bin/' + toolchain_prefix + 'gcc'
  AVIXY_CXX = path_to_toolchain + '/bin/' + toolchain_prefix + 'g++'
  AVIXY_LD = path_to_toolchain + '/bin/' + toolchain_prefix + 'gcc'
  AVIXY_AR = path_to_toolchain + '/bin/' + toolchain_prefix + 'ar'
  AVIXY_CFLAGS  = GCC_COMMON_CFLAGS  + ARCH_CFLAGS
  AVIXY_CXXFLAGS  = GCC_COMMON_CFLAGS  + ARCH_CFLAGS
  AVIXY_LDFLAGS = GCC_COMMON_LDFLAGS + ARCH_LDFLAGS
  AVIXY_SDK_WORKSPACE = "#{ENV['SDK_WORKSPACE_PATH']}"
  AVIXY_LIBRARIES_PATH = "#{AVIXY_SDK_WORKSPACE}/libraries"

  [conf.cc, conf.cxx, conf.objc, conf.asm].each do |cc|
    cc.command = AVIXY_CC
    cc.flags = AVIXY_CFLAGS
    cc.include_paths = ["#{root}/include"]
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/core/inc" 
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/avixy/inc" 
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/magcard/inc"
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/network/inc"
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/gprs/inc"
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/wifi/inc"
    cc.include_paths << "#{AVIXY_LIBRARIES_PATH}/ethernet/inc"
    cc.include_paths << "#{AVIXY_SDK_WORKSPACE}/avixy/4000/include"
  end

  conf.cc.defines << %w(SHA256_DIGEST_LENGTH=32 SHA512_DIGEST_LENGTH=64 MRB_STACK_EXTEND_DOUBLING) 
  conf.linker.command = AVIXY_LD
  conf.linker.flags = AVIXY_LDFLAGS
  conf.archiver.command = AVIXY_AR

  conf.linker.library_paths << "#{AVIXY_SDK_WORKSPACE}/libraries/avixy/SharedLib"    
  conf.linker.library_paths << "#{AVIXY_SDK_WORKSPACE}/libraries/network/SharedLib"    
  conf.linker.library_paths << "#{AVIXY_SDK_WORKSPACE}/libraries/gprs/SharedLib"
  conf.linker.library_paths << "#{AVIXY_SDK_WORKSPACE}/libraries/wifi/SharedLib"
  conf.linker.library_paths << "#{AVIXY_SDK_WORKSPACE}/libraries/ethernet/SharedLib"
  conf.linker.libraries << 'avixy'  
  conf.linker.libraries << 'network'  
  conf.linker.libraries << 'gprs'  
  conf.linker.libraries << 'wifi'  
  conf.linker.libraries << 'ethernet'

  conf.gembox File.join(AROUND_ROOT, "mrbgems", "around")
end
