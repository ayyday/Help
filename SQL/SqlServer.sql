use [DB_NAME]

--==================== WITH(NOLOCK) =============================
select * from [TABLE_NAME] WITH(NOLOCK)

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

--======================  sequences  ===========================
--[SEQUENCE_NAME] 設定於 DB->可程式性->順序
select s.name, s.increment, s.minimum_value, s.maximum_value, s.is_cached, s.is_cycling, s.current_value from sys.sequences s

--取得序號，且加自訂編碼方式
select FORMAT(GETDATE(), 'yyMMdd') + RIGHT( REPLICATE('0',3) + CAST(NEXT VALUE FOR [SEQUENCE_NAME] AS VARCHAR(3)), 3)

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
