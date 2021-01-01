
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tony Ropson 
-- Create date: 12/29/2020
-- Description:	This is a stored proc to test the differences between using transparent data encryption.  Make sure to have the logging 
-- =============================================

--- exec SPTestTDE
alter PROCEDURE SPTestTDE

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @RunStartTime [datetime2](7)
	declare @EncrytionIsOn int
	declare @lastRow int
	declare @CurrentCount int
    declare @totalCount int
	set @CurrentCount = 0
	---set this variable to the number of rows you want to insert
    set @totalCount = 100000

	--- If TDE is one = 1 else zero
	set @EncrytionIsOn = 1

	--creates the log table if doesn't exisit 
   IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LogTable]') AND type in (N'U'))
   BEGIN
   CREATE TABLE [dbo].[LogTable](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Run_ID] [uniqueidentifier] NULL,
	[Process_Name] [varchar](255) NOT NULL,
	[StartTime] [datetime2](7) NULL,
	[EndTime] [datetime2](7) NULL,
	[Encrypted] [int] Null
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

   END

 IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LogResourceStates]') AND type in (N'U'))
   BEGIN
   CREATE TABLE [dbo].[LogResourceStates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Run_ID] [uniqueidentifier] NULL,
	 [end_time] datetime NULL,
      [avg_cpu_percent] decimal(5,2) NULL,
      [avg_data_io_percent] decimal(5,2) NULL,
      [avg_log_write_percent] decimal(5,2) NULL,
      [avg_memory_usage_percent] decimal(5,2) NULL,
      [xtp_storage_percent] decimal(5,2) NULL,
      [max_worker_percent] decimal(5,2) NULL,
      [max_session_percent] decimal(5,2) NULL,
      [dtu_limit] decimal(5,2) NULL,
      [avg_login_rate_percent] decimal(5,2) NULL,
      [avg_instance_cpu_percent] decimal(5,2) NULL,
      [avg_instance_memory_percent] decimal(5,2) NULL,
      [cpu_limit] decimal(5,2) NULL,
      [replica_role] int null
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

   END





----create tables -------
--------------------------
declare @StartTime [datetime2](7)
declare @EndTime [datetime2](7)
declare @RUNID  [uniqueidentifier]
set @RunStartTime = GETDATE()
set @StartTime = GETDATE()
set @RUNID = NEWID()

CREATE TABLE [dbo].[Table1](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[col_1] [varchar](255) NOT NULL,
	[col_2] [int] NULL,
	[col_3] [uniqueidentifier] NULL,
	[CreatedDateTime] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Table1] ADD  DEFAULT (newid()) FOR [col_3]


ALTER TABLE [dbo].[Table1] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]

set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 1 Created'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

set @StartTime = GETDATE()


CREATE TABLE [dbo].[Table2](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Table1_ID] [int] NOT NULL,
	[col_1] [varchar](255) NOT NULL,
	[col_2] [int] NULL,
	[col_3] [uniqueidentifier] NULL,
	[CreatedDateTime] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[Table2] ADD  DEFAULT (newid()) FOR [col_3]


ALTER TABLE [dbo].[Table2] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]


ALTER TABLE [dbo].[Table2]  WITH CHECK ADD  CONSTRAINT [FK_Table1_Table1] FOREIGN KEY([Table1_ID])
REFERENCES [dbo].[Table1] ([Id])


ALTER TABLE [dbo].[Table2] CHECK CONSTRAINT [FK_Table1_Table1]


set @EndTime = GETDATE();
INSERT INTO [dbo].[LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 2 Created'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

set @StartTime = GETDATE()

CREATE TABLE [dbo].[Table3](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Table2_ID] [int] NOT NULL,
	[col_1] [varchar](255) NOT NULL,
	[col_2] [int] NULL,
	[col_3] [uniqueidentifier] NULL,
	[CreatedDateTime] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[Table3] ADD  DEFAULT (newid()) FOR [col_3]


ALTER TABLE [dbo].[Table3] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]


ALTER TABLE [dbo].[Table3]  WITH CHECK ADD  CONSTRAINT [FK_Table3_Table1] FOREIGN KEY([Table2_ID])
REFERENCES [dbo].[Table2] ([Id])


ALTER TABLE [dbo].[Table3] CHECK CONSTRAINT [FK_Table3_Table1]


set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 3 Created'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

		   ------- Tables inserts------------

While @CurrentCount <> @totalCount
BEGIN

BEGIN TRANSACTION [Tran1]

INSERT INTO [dbo].[Table1]
           ([col_1]
           ,[col_2]
          )
     VALUES (
           ABS(CHECKSUM(NewId())) % 100000000,
           ABS(CHECKSUM(NewId())) % 100000000
           )
set @lastRow = @@IDENTITY

INSERT INTO [dbo].[Table2]
           ([Table1_ID]
           ,[col_1]
           ,[col_2]
          )
     VALUES
           (@lastRow
            ,ABS(CHECKSUM(NewId())) % 100000000
           ,ABS(CHECKSUM(NewId())) % 100000000
          )

set @lastRow = @@IDENTITY

INSERT INTO [dbo].[Table3]
           ([Table2_ID]
           ,[col_1]
           ,[col_2]
           )
     VALUES
            (@lastRow
            ,ABS(CHECKSUM(NewId())) % 100000000
           ,ABS(CHECKSUM(NewId())) % 100000000
          )

 COMMIT TRANSACTION [Tran1]

 set @CurrentCount = @CurrentCount + 1
 END

 set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Rows Inserted'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)


-------- Table updates ------------

set @StartTime = GETDATE()
BEGIN TRANSACTION [Tran1]
UPDATE [dbo].[Table1]
   SET [col_1] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_2] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_3] = newid()
      ,[CreatedDateTime] =GETDATE()

 COMMIT TRANSACTION [Tran1]

  set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 1 updated'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)


set @StartTime = GETDATE()
 BEGIN TRANSACTION [Tran2]
UPDATE [dbo].[Table2]
   SET [col_1] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_2] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_3] = newid()
      ,[CreatedDateTime] =GETDATE()

 COMMIT TRANSACTION [Tran2]
 INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 2 updated'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)


 set @StartTime = GETDATE()
  BEGIN TRANSACTION [Tran3]
UPDATE [dbo].[Table3]
   SET [col_1] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_2] = ABS(CHECKSUM(NewId())) % 100000000
      ,[col_3] = newid()
      ,[CreatedDateTime] = GETDATE()

 COMMIT TRANSACTION [Tran3]

 INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID]
		   ,[Encrypted])
     VALUES
           ('Table 3 updated'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

----- Table indexes today -------

CREATE NONCLUSTERED INDEX [NonClusteredIndex-Table1] ON [dbo].[Table1]
(
	[Id] ASC,
	[col_1] ASC,
	[col_2] ASC,
	[col_3] ASC,
	[CreatedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [NonClusteredIndex-Table2] ON [dbo].[Table2]
(
	[Id] ASC,
	[col_1] ASC,
	[col_2] ASC,
	[col_3] ASC,
	[CreatedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [NonClusteredIndex-Table3] ON [dbo].[Table3]
(
	[Id] ASC,
	[col_1] ASC,
	[col_2] ASC,
	[col_3] ASC,
	[CreatedDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]







		   ---------------------------Table select ---------------------------------

declare @AvgInt int

set @StartTime = GETDATE()

--select @AvgInt = avg(t3.[col_2])
--FROM [TDETest].[dbo].[Table3] t3

SELECT TOP (3000) t1.[Id]
      , t1.[col_1]
      , t2.[col_2]
      , t1.[CreatedDateTime] as CreateTimeTable1
      ,t2.[CreatedDateTime] as  CreateTimeTable2
	  ,t3.[CreatedDateTime] as  CreateTimeTable3
	  INTO #TestSelectTemp
  FROM [TDETest].[dbo].[Table1] t1
  JOIN [TDETest].[dbo].[Table2] t2 on t1.Id = t2.Id
  JOIN [TDETest].[dbo].[Table3] t3 on t2.Id = t3.Id
 -- Where t3.[col_2] > = @AvgInt
  INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Table SelectSatement'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)


------- Table deletes ------------------------
set @StartTime = GETDATE()
DELETE FROM [dbo].[Table3]

  set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Table 1 deleted'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

 set @StartTime = GETDATE()    
DELETE FROM [dbo].[Table2]
  set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Table 2 deleted'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)

set @StartTime = GETDATE()
 DELETE FROM [dbo].[Table1]   
   set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Table 3 deleted'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)




	----------------drop tables ------------------------------

	set @StartTime = GETDATE()
/****** Object:  Table [dbo].[Table3]    Script Date: 12/29/2020 12:25:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Table3]') AND type in (N'U'))
DROP TABLE [dbo].[Table3]
BEGIN
set @EndTime = GETDATE();
 INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Drop Table 3'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)
END

set @StartTime = GETDATE()
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Table2]') AND type in (N'U'))
BEGIN
set @EndTime = GETDATE();
DROP TABLE [dbo].[Table2]
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Drop Table 2'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)
END
set @StartTime = GETDATE()
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Table1]') AND type in (N'U'))
BEGIN
DROP TABLE [dbo].[Table1]
set @EndTime = GETDATE();
INSERT INTO [LogTable]
           ([Process_Name]
           ,[StartTime]
           ,[EndTime]
		   ,[Run_ID],[Encrypted])
     VALUES
           ('Drop Table 1'
           ,@StartTime 
           ,@EndTime
		   ,@RUNID,@EncrytionIsOn)
END

INSERT INTO [dbo].[LogResourceStates]
           ([Run_ID]
           ,[end_time]
           ,[avg_cpu_percent]
           ,[avg_data_io_percent]
           ,[avg_log_write_percent]
           ,[avg_memory_usage_percent]
           ,[xtp_storage_percent]
           ,[max_worker_percent]
           ,[max_session_percent]
           ,[dtu_limit]
           ,[avg_login_rate_percent]
           ,[avg_instance_cpu_percent]
           ,[avg_instance_memory_percent]
           ,[cpu_limit])
   SELECT  @RUNID
       ,[end_time]
      ,[avg_cpu_percent]
      ,[avg_data_io_percent]
      ,[avg_log_write_percent]
      ,[avg_memory_usage_percent]
      ,[xtp_storage_percent]
      ,[max_worker_percent]
      ,[max_session_percent]
      ,[dtu_limit]
      ,[avg_login_rate_percent]
      ,[avg_instance_cpu_percent]
      ,[avg_instance_memory_percent]
      ,[cpu_limit]
    
  FROM [sys].[dm_db_resource_stats]
  where [end_time] > @RunStartTime


END