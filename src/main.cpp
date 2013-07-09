#include <iostream>
#include <vector>
#include <string>
#include <cmath>

#include <boost/python.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <frameobject.h>

namespace py = boost::python;
namespace fs = boost::filesystem;

static const std::string UPDATES_DIR = "updates";
static const std::string TEMP_PREFIX = "__tmp_";

void
removeTemps(const std::string source = ".")
{
  fs::path sourceDir(source);
  fs::directory_iterator end_iter;

  std::vector<fs::path> files;

  if (fs::exists(sourceDir) && fs::is_directory(sourceDir))
  {
    for(fs::directory_iterator dir_iter(sourceDir); dir_iter != end_iter; ++dir_iter)
    {
      if (fs::is_regular_file(dir_iter->status()))
      {
        auto filename = dir_iter->path().filename();
        if (boost::ends_with(filename.string(), TEMP_PREFIX))
        {
          std::cout << "remove " << dir_iter->path() << std::endl;
          fs::remove(dir_iter->path());
        }
      }
      else if (fs::is_directory(dir_iter->status()))
      {
        auto currentPath = dir_iter->path();
        removeTemps(currentPath.string());
      } // Ignore other kind of files for now
    }
  }
}

/**
   Given two directories, it merges them by copying new files and
   directories, and replacing existing files with the ones at the
   destination
 */
void
mergeDirectories(const fs::path &source,
                 const fs::path &dest)
{
  fs::path sourceDir(source);
  fs::directory_iterator end_iter;

  std::vector<fs::path> files;

  if (fs::exists(sourceDir) && fs::is_directory(sourceDir))
  {
    for(fs::directory_iterator dir_iter(sourceDir); dir_iter != end_iter; ++dir_iter)
    {
      if (fs::is_regular_file(dir_iter->status()))
      {
        auto filename = dir_iter->path().filename();
        auto destFilePath = dest / filename;
        std::cout << "copy_file " << dir_iter->path() << " to " << destFilePath << std::endl;
        if (fs::exists(destFilePath))
        {
          // On windows we can't remove, but we can rename and afterwards remove
          auto tempFilePath = dest / fs::path(filename.string() + TEMP_PREFIX);
          //fs::remove(destFilePath);
          fs::rename(destFilePath, tempFilePath);
        }
        copy_file(dir_iter->path(), destFilePath);
      }
      else if (fs::is_directory(dir_iter->status()))
      {
        auto currentPath = dir_iter->path();
        auto pathAtDest = dest / currentPath.filename();
        if (!fs::exists(pathAtDest))
        {
          // This just creates the directory
          copy_directory(currentPath, pathAtDest);
        }
        mergeDirectories(currentPath, pathAtDest);
      } // Ignore other kind of files for now
    }
  }
}

void
updateIfNeeded()
{
  fs::path updatePath(fs::current_path() / fs::path(UPDATES_DIR));
  if (fs::exists(updatePath))
  {
    std::cout << "Found updates, merging directories before doing anything..."
              << std::endl;
    mergeDirectories(updatePath, fs::current_path());
    fs::remove_all(updatePath);
  }
  else
  {
    std::cout << "No updates found" << std::endl;
    removeTemps();
  }
}

int
main(int argc, char** argv)
{
  try {
    fs::path full_path(fs::current_path());

    updateIfNeeded();

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
    

    py::exec_file("apps/launcher.py",
                  global,
                  global);
  } catch (py::error_already_set&) {
    PyErr_PrintEx(0);
    return 1;
  }
  return 0;
}
