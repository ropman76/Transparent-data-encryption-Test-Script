# Transparent-data-encryption-Test-Script
The script is to test the performance of having transparent data encryption (TDE) enabled in Azure

The Azure script uses a DMV to capture in the performance of the write heavy script.

Looking at the numbers TDE, effects write heavy performance about between 2 and 4%.  Using 2 V cores on serverless the performance was rather sluggish in comparision to running the same query locally for both enabled TDE and disabled TDE.  If there are performance issues, most likely TDE is not the cause.






