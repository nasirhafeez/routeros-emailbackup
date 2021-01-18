# Mikrotik RouterOS Automatic Backup and Email

This script provides an ability to send Mikrotik's daily backups to email.

## How to use
##### 1. Configure parameters
Take the  [script](https://github.com/nasirhafeez/routeros-emailbackup/blob/master/backup.rsc) and configure its parameters at the begining of the file.

**Imprtant!** Don't forget to provide correct email address for backups.

##### 2. Create new script
System -> Scripts [Add]  

**Imprtant!** Script name has to be `BackupAndUpdate`   
Put the script which you configured earlier into the source area.

![](https://github.com/nasirhafeez/routeros-emailbackup/blob/master/howto/script-name.png)  

##### 3. Configure E-mail server
Tools -> Email

Set your email server parameters.

![](https://github.com/nasirhafeez/routeros-emailbackup/blob/master/howto/email-config.png)  

To check email settings, send a test message by running the following command in terminal:
```
/tool e-mail send to="yourMail@example.com" subject="backup & update test!" body="It works!";
```

*For Gmail/G-Suite, enable Less Secure Apps in [Settings](https://myaccount.google.com/lesssecureapps).*

##### 4. Create scheduled task
System -> Scheduler [Add]  
Name: `Backup And Update`  
Start Time: `03:10:00`  
Interval: `1d 00:00:00`  
On Event: `/system script run BackupAndUpdate;`

![](https://github.com/nasirhafeez/routeros-emailbackup/blob/master/howto/scheduler-task.png)  
  
Or you can use this command to create the task:
```
/system scheduler add name="Firmware Updater" on-event="/system script run BackupAndUpdate;" start-time=03:10:00 interval=1d comment="" disabled=no
```
##### 5. Test the script
When everything is done, you need to test and make sure that the script is working correctly.  
To do so, open a New Terminal and Log window in your WinBox, then run the script manually by executing this command `/system script run BackupAndUpdate;` in Terminal.  
You will see the script working process in the log window. If the script finished without errors, check your email, there will be a fresh message with backups from your MikroTik waiting for you.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
