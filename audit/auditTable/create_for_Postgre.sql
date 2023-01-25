CREATE TABLE BellAudit(
	n serial primary key,
	dt timestamp DEFAULT CURRENT_TIMESTAMP,
	usr varchar(128) NULL,
	grp varchar(1024) NULL,
	name varchar(255) NULL,
	tags varchar(1024) NULL,
	execstatus varchar(65535) NULL);

create unique index BellAuditId on BellAudit (n);