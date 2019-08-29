
Snowball client
The Snowball client is the tool that you'll use to transfer data between your
workstation and the Snowball.  The client can also be used before you have
received a Snowball to estimate the speed of transfer you will see when
using the Snowball.   Instructions for using the client are given below.

Before you can use the Snowball you'll need to plug it into power and
network, and then press the power button above the digital display.

While the device is preparing, go to AWS Import/Export Management
Console (https://console.aws.amazon.com/importexport/home) from an
Internet browser on your computer to download your manifest file and
unlock code. Providing these two credentials when you start Snowball client
will authorize your access to the Snowball, and they are necessary to use
Snowball client, unless you're using the test command.  You can download
the credentials from the console by going to your dashboard, selecting the
job you want to use, and then clicking the "Credentials" button.

Installing the Snowball client

The Client is a command line tool that is compatible with Windows, Mac OSX, and Linux.  Install the client installer package from our website (need reference) and save it on your local disk.  To install or use the client you will need to open a command line window on your system.   To open the command line window on Microsoft Windows, click the Start button and then the All Programs.  Next click Accessories and Command Prompt.  On Mac click on your Applications icon in the Dock and go to the "Other" folder and then double click on the application named
"Terminal".

For Windows, open up the windows explorer in the directory were you have
saved the installer package and then double click the installer and follow the
instructions on the screen.

For Mac and Linux, the client is distributed as a tar file.  On Mac, after downloading the tar file:
1) Open a terminal window and run the command
      tar xf snowball-client-mac-1.0.0.tar.gz in the directory where the file was downloaded, typically your Downloads folder.
2) In that same window change to the directory snowball-client-mac-1.0.0 and then run the command install.sh
3) The Snowball client is now installed.

For Linux, after downloading the tar file:
1) Open a terminal window and run the command
tar xf snowball-client-linux-1.0.0.tar.gz
2) The snowball client is now installed and available by running the command
bin/snowball in the directory where you ran the tar command.

Using the Snowball Client
The Snowball client is a command line tool that is used to copy data to the
Snowball. To use this tool, first open a command line window on your system.

Before using the client, you first need to start it. You do this by typing

snowball start -i <IP address shown on your snowball> -m <Path to the
manifest file> -u < Unlock code for your manifest>.  For example:

snowball start -i 192.168.0.8 -m JID164d885d-bb25-
47a3-b0e4-ecd18ab2e425_manifest.bin -u a6gt3-8suds-
kshd6-7hhas-876as

Once the client has started you are ready to copy files to the Snowball.  To
copy a file to the snowball use the command

snowball cp <file> s3://<bucket name>.  For example:

snowball cp report.doc s3://reportsbucket

Where file is the path of the file you want to copy and bucket name is the
name of the bucket where you want the file to be placed once the snowball
has been received by Amazon and processed.

If you want to copy the contents of an entire directory from your local
machine to the Snowball you can use the -r option with the cp command.
For example:

snowball cp -r reports s3://reportsbucket

In addition to copying files the snowball client allows you to list the files on
the snowball, get the amount of free space, and remove files.  The client
also supports a test mode that you can use to estimate how long it will take
to copy files to the snowball.  For information on all of the commands
supported and their options, please see below.

You can get help for all commands by using the -h or --help options.  For
example snowball -h will give a list of all of the commands supported and
snowball cp -h will give help on the copy command.

Snowball commands
start	Starts the Snowball client.
snowball start -i [IP Address] -m
[Path\to\manifest\file] -u [unlock code]

Options:
-i, --ip	Used to provide the IP address of the
Snowball. The IP address can be found on the Snowball's digital
display.

-m, --manifest	Used to specify the path to the manifest
for your job. The manifest and unlock code are your credentials
to authorize your access to the Snowball. You can download
your credentials from the Snowball management console
(https://console.aws.amazon.com/importexport/home).

-u, --unlock code	Used to specify the unlock code for
your job. The unlock code is 29 characters long, including 25
alpha-numeric characters, and 4 dashes. (See manifest for more
information.)

stop	Stops the Snowball client.
snowball stop

ls		Lists the files on the Snowball. Using the command
without a path will list the buckets you specified for the job. Note that
when specifying a location on the Snowball, you must preface it with
'awsie://'.
snowball ls
snowball ls [s3://bucketname]
snowball ls [s3://bucketname/path]

cp		Copies files and folders between the Snowball and your
workstation. Note that when specifying a location on the Snowball,
you must preface it with s3://.

snowball cp source/path s3://bucket/path

Options:
-r, -R, --recursive	Recursively copy contents in
folders during the cp operation.

-v, -V, --verbose	Tells Snowball client to report back real-time
transfer speed data.

-t, -T	Specifies the destination folder, allowing you to
declare -t [s3://path/to/data/destination] at any point in the
command after snowball cp.

status	Reports the current status of the Snowball, including used
and available space.

snowball status

rm	Deletes files and folders on the Snowball. Note that you can't
use this command to delete local files on your workstation. Note that
when specifying a location on the Snowball, you must preface it with
s3://.
snowball rm s3://path\to\data\to\be\deleted

Options:
-r, -R, --recursive	Recursively delete contents in
folders during the rm operation.

test	Performs a test of the 'snowball cp' command, without
actually copying any data. This test allows you to determine the
expected time it takes to complete your transfer. You can run this test
command without creating a job. For more information, see our online
documentation
(http://docs.aws.amazon.com/awsimportexport/latest/DG/performan
ce.html).

snowball test path\to\data\source

Options:
-r, -R, --recursive	Recursively traverse folders during
the test operation.

-t, --time	Tells Snowball client to specify the number of
minutes that you'd like to run the test. The longer the test runs,
the more accurate the results will be. If you provide more time
than it would take for the transfer to complete, the test will end
after analyzing all files.  By default the test is run for one minute.

-v, -V, --verbose Tells Snowball client to report back
real-time transfer speed data during the test.

mkdir	Creates a new folder on the Snowball. Note that you can't
create a new folder at the root level. You can only create folders inside
buckets that already exist on the Snowball. As with other commands,
you need preface your path with s3:// and bucket name.

snowball mkdir s3://bucket/path

USEFUL LINKS
------------
AWSIE Management Console:
https://console.aws.amazon.com/importexport/home
AWSIE Forums: https://forums.aws.amazon.com/forum.jspa?forumID=204
AWSIE documentation:
http://docs.aws.amazon.com/awsimportexport/latest/DG/transfer-
data.html
