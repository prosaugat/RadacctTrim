# RadacctTrim
This Perl script is designed for maintaining a FreeRADIUS MySQL database by archiving and trimming the radacct table. The script automates the process of copying relevant data to an archive table (radacct_archive) and deleting old records from the main radacct table. The goal is to optimize database size and improve performance over time.
