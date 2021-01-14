# IMPORTANT!
# Minimum supported RouterOS version is v6.43.7

:local emailAddress "yourmail@example.com";

## Backup encryption password, no encryption if no password.
:local backupPassword ""

## If true, passwords will be included in exported config.
:local sensetiveDataInConfig false;

#Script messages prefix
:local SMP "MK Backup:"

:log info "\r\n$SMP script \"Mikrotik RouterOS automatic backup & update\" started.";

#Check proper email config
:if ([:len $emailAddress] = 0 or [:len [/tool e-mail get address]] = 0 or [:len [/tool e-mail get from]] = 0) do={
	:log error ("$SMP Email configuration is not correct, please check Tools -> Email. Script stopped.");   
	:error "$SMP bye!";
}

#Check if proper identity name is set
if ([:len [/system identity get name]] = 0 or [/system identity get name] = "MikroTik") do={
	:log warning ("$SMP Please set identity name of your device (System -> Identity), keep it short and informative.");  
};

############### vvvvvvvvv GLOBALS vvvvvvvvv ###############
# Function creates backups (system and config) and returns array with names
# Possible arguments: 
#	`backupName` 			| string	| backup file name, without extension!
#	`backupPassword`		| string 	|
#	`sensetiveDataInConfig`	| boolean 	|
# Example:
# :put [$buGlobalFuncCreateBackups name="daily-backup"];

:global buGlobalFuncCreateBackups do={
	:log info ("$SMP Global function \"buGlobalFuncCreateBackups\" was fired.");  
	
	:local backupFileSys "$backupName.backup";
	:local backupFileConfig "$backupName.rsc";
	:local backupNames {$backupFileSys;$backupFileConfig};

	## Make system backup
	:if ([:len $backupPassword] = 0) do={
		/system backup save dont-encrypt=yes name=$backupName;
	} else={
		/system backup save password=$backupPassword name=$backupName;
	}
	:log info ("$SMP System backup created. $backupFileSys");   

	## Export config file
	:if ($sensetiveDataInConfig = true) do={
		/export compact file=$backupName;
	} else={
		/export compact hide-sensitive file=$backupName;
	}
	:log info ("$SMP Config file was exported. $backupFileConfig");   

	#Delay after creating backups
	:delay 5s;	
	:return $backupNames;
}

############### ^^^^^^^^^ GLOBALS ^^^^^^^^^ ###############

#Current date time in format: 2020jan15-221324 
:local dateTime ([:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . "-" . [:pick [/system clock get time] 0 2] . [:pick [/system clock get time] 3 5] . [:pick [/system clock get time] 6 8]);

:local deviceRbModel			[/system routerboard get model];
:local deviceRbSerialNumber 	[/system routerboard get serial-number];
:local deviceIdentityName 		[/system identity get name];
:local deviceIdentityNameShort 	[:pick $deviceIdentityName 0 18];

:local mailSubject   		"$SMP Device - $deviceIdentityNameShort:";
:local mailBody 	 		"";

:local mailBodyDeviceInfo	"\r\n\r\nDevice information: \r\nIdentity: $deviceIdentityName \r\nModel: $deviceRbModel \r\nSerial number: $deviceRbSerialNumber \r\n";

:local backupName 			"$deviceIdentityName.$deviceRbModel.$deviceRbSerialNumber.$dateTime";

:local backupNameFinal		$backupName;
:local mailAttachments		[:toarray ""];

:log info ("$SMP Creating system backups.");

:set mailSubject	($mailSubject . " Backup was created.");
:set mailBody		($mailBody . "Device config & system backup were created and attached to this email.");

:set mailAttachments [$buGlobalFuncCreateBackups backupName=$backupNameFinal backupPassword=$backupPassword sensetiveDataInConfig=$sensetiveDataInConfig];

# Combine fisrst step email
:set mailBody ($mailBody . $mailBodyDeviceInfo . $mailBodyCopyright);

# Remove functions from global environment to keep it fresh and clean.
:do {/system script environment remove buGlobalFuncCreateBackups;} on-error={}

##
## SENDING EMAIL

:log info "$SMP Sending email message, it will take around half a minute...";
:do {/tool e-mail send to=$emailAddress subject=$mailSubject body=$mailBody file=$mailAttachments;} on-error={
	:delay 5s;
	:log error "$SMP could not send email message ($[/tool e-mail get last-status]). Going to try it again in a while."

	:delay 5m;

	:do {/tool e-mail send to=$emailAddress subject=$mailSubject body=$mailBody file=$mailAttachments;} on-error={
		:delay 5s;
		:log error "$SMP could not send email message ($[/tool e-mail get last-status]) for the second time."
	}
}

:delay 30s;

:if ([:len $mailAttachments] > 0 and [/tool e-mail get last-status] = "succeeded") do={
	:log info "$SMP File system cleanup."
	/file remove $mailAttachments; 
	:delay 2s;
}

:log info "$SMP script \"Mikrotik RouterOS automatic backup & update\" completed it's job.\r\n";