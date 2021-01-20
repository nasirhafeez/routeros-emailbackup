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

<img src="https://github.com/nasirhafeez/routeros-emailbackup/blob/master/howto/email-config.png" alt="email config" width="350" height="200">

To check email settings, send a test message by running the following command in terminal:
```
/tool e-mail send to="yourMail@example.com" subject="backup & update test!" body="It works!";
```

*For Gmail/G-Suite, enable Less Secure Apps in [Settings](https://myaccount.google.com/lesssecureapps).*

##### 4. Create scheduled task
  
Use this command to create the task:
```
:local hour [:pick [/system clock get time] 0]; :local min [:pick [/system clock get time] 3 5]; :local stime "0$hour:$min:00"; /system scheduler add name="Backup Email" on-event="/system script run BackupAndUpdate;" start-time=$stime interval=1d comment="" disabled=no
```
It will create a script that runs at a random time between `00:00:00` to `02:59:00` everyday.

![](https://github.com/nasirhafeez/routeros-emailbackup/blob/master/howto/scheduler-task.png)  

##### 5. Test the script
When everything is done, you need to test and make sure that the script is working correctly.  
To do so, open a New Terminal and Log window in your WinBox, then run the script manually by executing this command `/system script run BackupAndUpdate;` in Terminal.  
You will see the script working process in the log window. If the script finished without errors, check your email, there will be a fresh message with backups from your MikroTik waiting for you.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
