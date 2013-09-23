
logfilename = "test.log"

import subprocess
import urllib
import os

logfile = open(logfilename, 'w')

cwd = os.path.dirname(os.path.abspath(__file__))
salt_dir = os.path.dirname(cwd)

testcases = ["vagrant-centos",
             "vagrant-debian",
             "vagrant-ubuntu"]
# print salt_dir
# print cwd
# quit()
for case in testcases:
    print "Testing case %s" % case
    logfile.write("Test Case: %s\n\n" % case)
    subprocess.call("vagrant destroy -f", cwd=os.path.join(salt_dir, case),
                    stdout=logfile, stderr=subprocess.STDOUT, shell=True)
    subprocess.call("vagrant up --no-provision", cwd=os.path.join(salt_dir, case),
                    stdout=logfile, stderr=subprocess.STDOUT, shell=True)
    subprocess.call("vagrant provision", cwd=os.path.join(salt_dir, case),
                    stdout=logfile, stderr=subprocess.STDOUT, shell=True)
    urllib.urlretrieve("http://localhost:8000", "%s-index.html" % case)
    subprocess.call("vagrant destroy -f", cwd=os.path.join(salt_dir, case),
                    stdout=logfile, stderr=subprocess.STDOUT, shell=True)
    print "Test result"
    if subprocess.call("diff index.html %s-index.html" % case, shell=True) == 0:
        print "Test successful"
    else:
        print "Check logfiles for errors"

logfile.close()
