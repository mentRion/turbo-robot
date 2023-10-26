
--UPDATE HPCOMMON..Item_Master SET options = 'N' where itemcode = 'A00A000040' AND U_Uom = 'BOX'
--update HPCOMMON..Item_Master SET options = 'N' where itemcode = 'A00A000030'  AND U_Uom = 'BOX'
--update HPCOMMON..Item_Master SET options = 'N' where itemcode = 'A00A000031' AND U_Uom = 'SET'

SELECT * FROM HPCOMMON..Item_Master where itemcode = 'A00A000040' UNION ALL
SELECT * FROM  HPCOMMON..Item_Master where itemcode = 'A00A000030' UNION all
SELECT * FROM  HPCOMMON..Item_Master where itemcode = 'A00A000031'

BEGIN TRAN
delete HPCOMMON..Item_Master where itemcode = 'A00A000040' AND U_Uom = 'BOX'
delete HPCOMMON..Item_Master where itemcode = 'A00A000030'  AND U_Uom = 'BOX'
delete HPCOMMON..Item_Master  where itemcode = 'A00A000031' AND U_Uom = 'SET'
ROLLBACK TRAN
COMMIT TRAN

CREATE TABLE #temptable ( [ItemCode] varchar(500), [ItemName] nvarchar(255), [U_Uom] varchar(255), [U_Conv] float(8), [Options] nvarchar(255), [Interval] int, [Limit] int, [DType] varchar(15), [ItmCat] varchar(5), [AppStat] int, [MaxQty] int, [ItemDesc] varchar(max), [ItemPic] image, [Modby] varchar(50), [ModDate] datetime, [ItemUse] varchar(max), [Accounting] varchar(100), [Clients] char(1), [EffectivityDate] date )
INSERT INTO #temptable ([ItemCode], [ItemName], [U_Uom], [U_Conv], [Options], [Interval], [Limit], [DType], [ItmCat], [AppStat], [MaxQty], [ItemDesc], [ItemPic], [Modby], [ModDate], [ItemUse], [Accounting], [Clients], [EffectivityDate])
VALUES
( 'A00A000040', N'FACILITIES - DOOR CLOSER 33mm', 'BOX', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ), 
( 'A00A000030', N'FACILITIES - EZSET LEVERSET ENTRANCE CAMBRIDGE', 'BOX', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ), 
( 'A00A000031', N'FACILITIES - EZSET LEVERSET PRIVACY CAMBRIDGE', 'SET', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL )

DROP TABLE #temptable












--item on hand
--check item 
Select * from hpdi..oinm where itemcode = 'A00A000040'
Select * from hpdi..oinm where itemcode = 'A00A000030'
Select * from hpdi..oinm where itemcode = 'A00A000031'

--item activation
SELECT * FROM HPCOMMON..Item_Master where itemcode = 'A00A000040' UNION ALL
SELECT * FROM HPCOMMON..Item_Master where itemcode = 'A00A000030' UNION all
SELECT * FROM HPCOMMON..Item_Master where itemcode = 'A00A000031'

Select * from Hpcommon..CONV WHERE U_ItemCode = 'A00A000040'
Select * from Hpcommon..CONV WHERE U_ItemCode = 'A00A000030' AND U_UoM = 'BOX'
Select * from Hpcommon..CONV WHERE U_ItemCode = 'A00A000031' AND U_UoM = 'SET'

DELETE Hpcommon..CONV WHERE U_ItemCode = 'A00A000030' AND U_UoM = 'BOX'
DELETE Hpcommon..CONV WHERE U_ItemCode = 'A00A000031' AND U_UoM = 'SET'

BEGIN TRAN
delete HPCOMMON..Item_Master where itemcode = 'A00A000040' AND U_Uom = 'BOX'
delete HPCOMMON..Item_Master where itemcode = 'A00A000030'  AND U_Uom = 'BOX'
delete HPCOMMON..Item_Master  where itemcode = 'A00A000031' AND U_Uom = 'SET'
COMMIT TRAN
ROLLBACK TRAN

SELECT * FROM HPCOMMON..Item_Master

SELECT * FROM  hpdi..oitm WHERE ItemCode = 'A00A000040' 
SELECT * FROM  hpdi..oitm WHERE ItemCode = 'A00A000030'
SELECT * FROM  hpdi..oitm WHERE ItemCode = 'A00A000031'

UPDATE hpdi..oitm set U_Pack = 0 WHERE ItemCode = 'A00A000040' 
UPDATE hpdi..oitm set U_Pack = 0 WHERE ItemCode = 'A00A000030'
UPDATE hpdi..oitm set U_Pack = 0 WHERE ItemCode = 'A00A000031'


CREATE TABLE #temptable ( [ItemCode] varchar(500), [ItemName] nvarchar(255), [U_Uom] varchar(255), [U_Conv] float(8), [Options] nvarchar(255), [Interval] int, [Limit] int, [DType] varchar(15), [ItmCat] varchar(5), [AppStat] int, [MaxQty] int, [ItemDesc] varchar(max), [ItemPic] image, [Modby] varchar(50), [ModDate] datetime, [ItemUse] varchar(max), [Accounting] varchar(100), [Clients] char(1), [EffectivityDate] date )
INSERT INTO HPCOMMON.dbo.ITEM_MASTER_BAK ([ItemCode], [ItemName], [U_Uom], [U_Conv], [Options], [Interval], [Limit], [DType], [ItmCat], [AppStat], [MaxQty], [ItemDesc], [ItemPic], [Modby], [ModDate], [ItemUse], [Accounting], [Clients], [EffectivityDate])
VALUES

( 'A00A000040', N'FACILITIES - DOOR CLOSER 33mm', 'BOX', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ), 
( 'A00A000030', N'FACILITIES - EZSET LEVERSET ENTRANCE CAMBRIDGE', 'BOX', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ), 
( 'A00A000031', N'FACILITIES - EZSET LEVERSET PRIVACY CAMBRIDGE', 'SET', 1, N'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL )

DROP TABLE #temptable

SELECT * FROM  HPCOMMON.dbo.ITEM_MASTER_BAK

SELECT * FROM dbo.SAPSet


