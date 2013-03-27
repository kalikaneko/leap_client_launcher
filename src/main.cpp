#include <iostream>
#include <vector>
#include <string>

#include <boost/python.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <frameobject.h>

namespace py = boost::python;
namespace fs = boost::filesystem;

int
main(int argc, char** argv)
{
  try {
    fs::path full_path(fs::current_path());

    Py_Initialize();

    Py_SetPythonHome(const_cast<char*>(full_path.string().c_str()));

    py::object main_module = py::import("__main__");
    py::object global = (main_module.attr("__dict__"));

    PySys_SetArgv(argc, argv);

    /* this does not work inside a bundle */
    global["_pwd"] = full_path.string();

    py::exec(
      "import os\n"
      "import sys\n"
      "import site\n"
      "old_syspath = sys.path\n"
      "sys.path = [_pwd + '/lib',\n"  /* XXX not needed after site init */
      "            _pwd + '/lib/site-packages',\n"
      "            _pwd + '/apps',\n"
      "            _pwd + '/apps/eip',\n"
      "            _pwd]\n"
      "site.addsitedir(_pwd + '/lib/site-packages')\n"
      "if sys.platform == 'darwin':\n"
      "    sys.path = sys.path + old_syspath\n"
      "print '[+ DEBUG: sys.path]'\n"
      "for p in sys.path: print p\n"
      "print '[+ DEBUG]'\n"
      "import os\n"
      "import encodings.idna\n" // we need to make sure this is imported
      /* XXX DEBUG */
      "print _pwd\n"
      "print os.path.abspath(_pwd)\n"
      "if not os.path.isfile(os.path.join(os.path.abspath(_pwd), 'apps', 'leap', 'app.py')):\n"
      "    print '[ERROR] apps/leap/app.py not found in the current folder, quitting.'\n"
      "    sys.exit(1)\n"
      /* XXX in osx we should only pass this if not inside a bundle */
      "sys.argv.append('--standalone')\n"
      "sys.argv.append('--debug')\n", global, global);
    

    py::exec_file("apps/leap/app.py",
                  global,
                  global);
  } catch (py::error_already_set&) {
    PyErr_PrintEx(0);
    return 1;
  }
  return 0;
}
