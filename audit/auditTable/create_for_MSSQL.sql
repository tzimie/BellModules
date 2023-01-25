use BellAuditDb
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BellAudit](
	[n] [int] IDENTITY(1,1) NOT NULL,
	[dt] [datetime] NULL,
	[usr] [varchar](128) NULL,
	[grp] [varchar](1024) NULL,
	[name] [varchar](255) NULL,
	[tags] [varchar](1024) NULL,
	[execstatus] varchar(max) NULL,
PRIMARY KEY CLUSTERED 
(
	[n] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE procedure [dbo].[DoAudit] 
  @usr varchar(128), @grp varchar(1024), @name varchar(255), @tags varchar(1024), @execstatus varchar(max)
as
  set nocount on
  insert into BellAudit (dt, usr,grp,name,tags,execstatus)
    select getdate(),@usr,@grp,@name,@tags,@execstatus
GO

