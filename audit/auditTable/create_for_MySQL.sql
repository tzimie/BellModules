create database BellAuditDb;

use BellAuditDb;

CREATE TABLE BellAudit (
	n INT NOT NULL AUTO_INCREMENT,
	dt timestamp DEFAULT CURRENT_TIMESTAMP,
	usr varchar(128) NULL,
	grp varchar(1024) NULL,
	name varchar(255) NULL,
	tags varchar(1024) NULL,
	execstatus varchar(10000) NULL,
        PRIMARY KEY (n)
);

