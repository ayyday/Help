use [DbName]


SELECT col.* ,obj.*
from sys.objects obj 
inner join sys.columns col 
on obj.object_Id=col.object_Id 
and obj.Name='[TableName]'


SELECT obj.*
from sys.objects obj 
where obj.Name='[TableName]'

--upd Column
ALTER TABLE [dbo].[TableName] ALTER COLUMN [ColName] nvarchar(300) NULL

--add Column
ALTER TABLE [dbo].[TableName] ADD [ColName] varchar(1) NULL



--刪除主索引鍵 : https://docs.microsoft.com/zh-tw/sql/relational-databases/tables/delete-primary-keys?view=sql-server-2017
USE [DCAB_WebAPI]
GO
-- Return the name of primary key.  
SELECT name  
FROM sys.key_constraints  
WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = N'[TableName]';  

-- Delete the primary key constraint.  
ALTER TABLE [dbo].[TableName]
DROP CONSTRAINT [PK_Name] --PK Name = PK_TableName
GO 


--full join
select *
from (select 'A' as k, '1' as v) a
full join (select 'A' as k, '2' as v) b on a.k = b.k
full join (select 'B' as k, '3' as v) c on a.k = c.k


--==================== WITH(NOLOCK) =============================
select * from [dbo].[TableName] WITH(NOLOCK)

--====================  convert  =============================
declare @Date datetime
select @Date = convert(datetime, '20181002', 112)
select @Date


declare @MaxDateTime datetime
select @MaxDateTime = convert(datetime, '9999/12/31 23:59:00', 111)
select @MaxDateTime

--function
select FORMAT(GETDATE(),'yyyyMMddHHmmss') BindTime
     , FORMAT(GETDATE(),'yyyy/MM/dd HH:mm:ss') BindTime2
     , FORMAT(GETDATE(),'yy/MM/dd HH:mm:ss') BindTime3


select 'a' + char(13) + char(10) + 'b'

select Isnull(a, 0)
from (
	select NULL as a
) b


select convert(int, '123') + 5000 as ConvertInt
select cast('123' as int) + 5000 as ConvertInt


--時間相間取分鐘
declare @GLSendTime DateTime  = convert(datetime, '2019/05/31 13:39:59', 111)
declare @CurDateTime DateTime  = getdate()
select @GLSendTime as GLSendTime
, @CurDateTime as CurDateTime
, DATEDIFF(mi, isnull(@GLSendTime, getdate()),@CurDateTime) AS GLdiffTime

--DateTime add Day, Month, Year
--https://docs.microsoft.com/zh-tw/sql/t-sql/functions/dateadd-transact-sql?view=sql-server-2017
select getdate()
, DATEADD(DAY, 1, getdate()) as addDay, DATEADD(DAY, -1, getdate()) as deDay
, DATEADD(MONTH, 1, getdate()) as addMon, DATEADD(MONTH, -1, getdate()) as deMon
, DATEADD(YEAR, 1, getdate()) as addYear, DATEADD(YEAR, -1, getdate()) as deYear
--======================  換行  ===========================
/*
https://www.cnblogs.com/xiaotiannet/p/3510586.html
回車 Carriage Return 和 換行 Line Feed 這兩個概念的來歷和區別。
符號   ASCII碼  意義
\r     13       回車CR
\n     10       換行


--aaa\r\nbbb
*/
select 'a' + char(13) + char(10) + 'b'
select 'c' + char(13) + 'd'
select 'e' + char(10) + 'f'

select ASCII('''')
select char(ASCII(''''))


--====================== 多行合併為一行  ===========================
declare @Text varchar(2000)
set @Text = ''
select @Text = @Text + case when @Text <> '' then ', ' else '' end + d.col
from (
	select 'a' as col union 
	select 'b' as col union 
	select 'c' as col
) d
select @Text as col

--======================  sequences + 補長度  ===========================
select s.name, s.increment, s.minimum_value, s.maximum_value, s.is_cached, s.is_cycling, s.current_value from sys.sequences s

-- 遞增順序：DB/可程式性/順序/(SEQUENCE)[SeqName]
select FORMAT(GETDATE(), 'yyMMdd') + RIGHT( REPLICATE('0',3) + CAST(NEXT VALUE FOR [SeqName] AS VARCHAR(3)), 3)

select s.name, s.increment, s.minimum_value, s.maximum_value, s.is_cached, s.is_cycling, s.current_value from sys.sequences s


--補長度
declare @tempSeq varchar(30)
declare @totLen int = 5
select REPLICATE('0',@totLen)
select @tempSeq = REPLICATE('0',@totLen) + 'abc'
select @tempSeq
select RIGHT(@tempSeq, @totLen) 


--======================  in (string)  ===========================
with d as (
	select 'S' as result, 'S' status
	union
	select 'S' as result, 'P' status
	union
	select 'F' as result, 'W' status
	union
	select 'F' as result, 'A' status
	union
	select 'S' as result, 'E' status
	union
	select 'F' as result, 'E' status
),
v as (
	select 'S' as code, '''S'',''P''' as CodeVal2
	union
	select 'F' as code, '''W'',''A''' as CodeVal2
)
select *
from d
left join v on d.result = v.code and v.CodeVal2 like '%''' + d.status + '''%' 


--====================  With table & row_number  =============================
--(1) [Server 2017] https://docs.microsoft.com/zh-tw/sql/t-sql/functions/string-split-transact-sql?view=sql-server-2017
/*
DECLARE @tags NVARCHAR(400) = 'clothing,road,,touring,bike'  
  
SELECT value  
FROM STRING_SPLIT(@tags, ',')  
WHERE RTRIM(value) <> '';
*/

--(2) https://stackoverflow.com/questions/10914576/t-sql-split-string
/*
CREATE FUNCTION dbo.splitstring ( @stringToSplit VARCHAR(MAX) )
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(',', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(',', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

 RETURN
END

SELECT * FROM dbo.splitstring('91,12,65,78,56,789')
*/



DECLARE @stringToSplit VARCHAR(MAX) = '1,91,12,65,78,56,789'
DECLARE @returnList TABLE ([Name] [nvarchar] (500))

 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(',', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(',', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit

select * from @returnList

--====================  With table & row_number  =============================
with t1 as (select 1 as idx, 'a1' A union all
            select 1 as idx, 'a1' A
            ), 
     t2 as (select 1 as idx, 'b' B)
select t1.*, t2.*, row_number() over(partition by t1.idx order by t1.A desc) as rowid
from t1 
join t2 on t1.idx = t2.idx


--==================== Temp table  =============================
--https://social.msdn.microsoft.com/Forums/zh-TW/850f5bf2-79b5-4f32-ba40-0bba2db1e929/2431431435temptable33287declare-temptable26377203092404621029?forum=240

--方法一
Create Table #TempTable(
FirstName varchar(20),
LastName varchar(20)
)
Drop Table #TempTable

--方法二
DECLARE @TmpTable TABLE (
FirstName varchar(20), 
LastName varchar(20)
)
/*
方法一是建立一個區域性的暫存資料表（Local ），
簡單地說，就是在 tempdb 資料庫中，建立一個名稱為 #TempTabel 的資料表（位於暫存資料表中），
這個暫存資料表只有建立者可以使用，其他人可以看到，但無法存取。
除非利用 DROP TABLE 來明確卸除暫存資料表，否則當建立該暫存資料表的連線結束時，SQL Server 會自動將其刪除。


而方法二則是建立一個 table 資料型別的暫存資料表，
它是存在記憶體中的。因此其他人無法看到，
此外當定義 table 資料型別的函數、預存程序或批次結束時，就會自動清除這個暫存資料表。
*/


--===========================================================
--         [1] update from table  
--         [2] MERGE insert or update from table 
-- ==========================================================
--https://docs.microsoft.com/zh-tw/sql/t-sql/statements/merge-transact-sql
--https://chartio.com/resources/tutorials/how-to-update-from-select-in-sql-server/

Create Table #Table1 (Seq smallint,  Name varchar(20), editTime datetime)
Create Table #Table2 (Seq smallint,  Name varchar(20), editTime datetime)
Drop Table #Table1
Drop Table #Table2

delete #Table1
delete #Table2
insert #Table1(Seq, Name, editTime) values(1, 'a', GETDATE())
insert #Table1(Seq, Name, editTime) values(2, 'b', GETDATE())
insert #Table2(Seq, Name, editTime) values(1, 'cc', GETDATE())
insert #Table2(Seq, Name, editTime) values(3, 'dd', GETDATE())

select * from #Table1
select * from #Table2

--[1.1] update ok
UPDATE #Table1
SET #Table1.Name = t2.Name
   ,#Table1.editTime = GETDATE()
FROM #Table1 
INNER JOIN #Table2 t2 ON #Table1.Seq = t2.Seq 
WHERE t2.Seq = 1

--[1.2] update ok
UPDATE #Table1
SET #Table1.Name = t2.Name
   ,#Table1.editTime = GETDATE()
FROM #Table2 t2
WHERE t2.Seq = 1 and #Table1.Seq = t2.Seq 


--[2.1]merge all, count =2
MERGE INTO  #Table1
USING       #Table2 t2
ON          #Table1.Seq = t2.Seq
WHEN MATCHED THEN
		UPDATE SET  #Table1.Name = t2.Name
		           ,#Table1.editTime = GETDATE()
WHEN NOT MATCHED THEN
		INSERT  (Seq, Name, editTime)
		VALUES  (t2.Seq, t2.Name, GETDATE());

--[2.2]merge where, count =1
MERGE INTO  #Table1
USING       (select * from #Table2 where seq = 3) t2
ON          #Table1.Seq = t2.Seq
WHEN MATCHED THEN
		UPDATE SET  #Table1.Name = t2.Name
		           ,#Table1.editTime = GETDATE()
WHEN NOT MATCHED THEN
		INSERT  (Seq, Name, editTime)
		VALUES  (t2.Seq, t2.Name, GETDATE());


/*
UPDATE books
SET    books.primary_author = authors.name
FROM   books
INNER JOIN  authors ON books.author_id = authors.id
WHERE books.title = 'The Hobbit'

MERGE INTO books
USING authors
ON  books.author_id = authors.id
WHEN MATCHED THEN
	UPDATE SET books.primary_author = authors.name
WHEN NOT MATCHED THEN
	INSERT (books.author_id, books.primary_author)
	VALUES (authors.id, authors.name)

--https://dotblogs.com.tw/dc690216/2010/01/25/13313
--將兩張表 MERGE
--當兩張表有資料 MERGE 時，且 庫存量 加上 進退貨量 等於零時，則刪除資料
--當兩張表有資料 MERGE 時，將 庫存量 加上 進退貨量 更新到 庫存量
--當兩張表沒有資料 MERGE 時，將 進退貨倉庫 的資料新增到 大倉庫 中
MERGE INTO 大倉庫
   USING 進退貨倉庫
   ON 大倉庫.品名 = 進退貨倉庫.品名
WHEN MATCHED AND (大倉庫.庫存量 + 進退貨倉庫.進退貨量 = 0) THEN
   DELETE
WHEN MATCHED THEN
   UPDATE SET 大倉庫.庫存量 = 大倉庫.庫存量 + 進退貨倉庫.進退貨量
WHEN NOT MATCHED THEN
   INSERT VALUES(進退貨倉庫.品名, 進退貨倉庫.進退貨量);

--查詢 MERGE 後的結果
Select * From dbo.大倉庫
Select * From dbo.進退貨倉庫
*/


--===========================================================
--Sleep Command in T-SQL
--https://stackoverflow.com/questions/664902/sleep-command-in-t-sql
--===========================================================
select GETDATE()
-- wait for 1 minute
WAITFOR DELAY '00:20' select GETDATE()
-- wait for 1 second
WAITFOR DELAY '00:00:01'
select GETDATE()
