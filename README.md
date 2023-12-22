# RadacctTrim
This Perl script is designed for maintaining a FreeRADIUS MySQL database by archiving and trimming the radacct table. The script automates the process of copying relevant data to an archive table (radacct_archive) and deleting old records from the main radacct table. The goal is to optimize database size and improve performance over time.

#Why this script ?
Archive and trim operation for FreeRADIUS MySQL databases.
Automated checks for the existence of the database and archive table.
Copying records from the main table to the archive table based on specific conditions.
Deleting old records from the main table to keep it compact.

** Feel free to contribute, provide feedback, or customize the script based on your specific needs!
