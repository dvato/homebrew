require 'formula'

def which_python
  "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
end

def site_package_dir
  "lib/#{which_python}/site-packages"
end

class Pyside < Formula
  homepage 'http://www.pyside.org'
  # See https://github.com/mxcl/homebrew/issues/15190
  url 'https://distfiles.macports.org/py-pyside/pyside-qt4.8+1.1.2.tar.bz2'
  # url 'http://www.pyside.org/files/pyside-qt4.8+1.1.2.tar.bz2'
  sha1 'c0119775f2500e48efebdd50b7be7543e71b2c24'

  depends_on 'cmake' => :build
  depends_on 'shiboken'

  def install
    # The build will be unable to find Qt headers buried inside frameworks
    # unless the folder containing those frameworks is added to the compiler
    # search path.
    qt = Formula.factory 'qt'
    ENV.append_to_cflags "-F#{qt.prefix}/Frameworks"

    # Also need `ALTERNATIVE_QT_INCLUDE_DIR` to prevent "missing file" errors.
    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    args = std_cmake_args + %W[
      -DALTERNATIVE_QT_INCLUDE_DIR=#{qt.prefix}/Frameworks
      -DSITE_PACKAGE=#{site_package_dir}
      -DBUILD_TESTS=NO
      ..
    ]
    mkdir 'macbuild' do
      system 'cmake', *args
      system 'make'
      system 'make install'
    end
  end

  def caveats
    <<-EOS
PySide Python modules have been linked to:
    #{HOMEBREW_PREFIX}/#{site_package_dir}

Make sure this folder is on your PYTHONPATH. For PySide development tools,
install the `pyside-tools` formula.
    EOS
  end
end
