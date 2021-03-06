import os
import time
import threading

from leap.app import main as leap_client
from thandy.ClientCLI import update as thandy_update


class Thandy(threading.Thread):
    def run(self):
        while True:
            try:
                os.environ["THANDY_HOME"] = os.path.join(os.getcwd(),
                                                         "config",
                                                         "thandy")
                os.environ["THP_DB_ROOT"] = os.path.join(os.getcwd(),
                                                         "packages")
                os.environ["THP_INSTALL_ROOT"] = os.path.join(os.getcwd(),
                                                              "updates")
                args = [
                    "--repo=repo/",
                    "--debug",  # TODO: remove debug
                    "--install",
                    "/bundleinfo/LEAPClient/"
                ]
                thandy_update(args)
            except Exception as e:
                print "ERROR1:", e
            finally:
                time.sleep(60)


if __name__ == "__main__":
    thandy_thread = Thandy()
    thandy_thread.daemon = True
    thandy_thread.start()

    leap_client()
