/****** Object:  StoredProcedure [Vehicle].[VHChargeDetailInsert]    Script Date: 23/2/2016 9:39:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











--============================================================================================================================  
-- Created By : Arulprakasan  
-- Created date:  23-Sep-2009  
-- Modified By:Arulprakasan  
-- Last Modified Date:   
-- Module     : Store  
-- Screen(s)  : Store Issue Voucher Approval  
-- Description: To Save Values in vehicle.vhchargedetail table  
--============================================================================================================================  
  
ALTER PROCEDURE [Vehicle].[VHChargeDetailInsert]  
 @EstateCodeL nvarchar(50),  
 @VHWSCode nvarchar(50),  
 @EstateCode nvarchar(50),  
 @VHDetailCostCode nvarchar(50),  
 @Type nvarchar(1),  
 @ModName nvarchar(50),  
 @AYear numeric(18,0),  
 @AMonth int,   
 @Value numeric(18,0),  
 @JDescp nvarchar(300),  
--@ConcurrencyId rowversion output,  
 @CreatedBy nvarchar(50),  
 @CreatedOn datetime,  
 @ModifiedBy nvarchar(50),  
 @ModifiedOn datetime  ,
 @LedgerType nvarchar(50),
 @LedgerNo nvarchar(50),  
 @UOMID nvarchar(50),
 @QtyUsed numeric(18,3),
 @RefNo nvarchar(50) 	
AS   
DECLARE @VHChargeDetailID nvarchar(50),@ModID int
--,@LedgerType nvarchar(50),@LedgerNo nvarchar(50)  
   
BEGIN TRY  
      
    --Declare @count int  
    BEGIN   
    --SET @count = 0;  
          
    --SELECT @count =CAST(( CASE WHEN (ISNULL(MAX(Id), -1) = -1 ) THEN 1 WHEN MAX(Id) >= 0 THEN MAX(Id) + 2 END ) AS VARCHAR)   
    --   FROM Vehicle.VHChargeDetail  
    --SET @VHChargeDetailID = @EstateCode+'R'+ + CONVERT(NVARCHAR,@count);  
  
   DECLARE @i INT = 2
	SELECT @VHChargeDetailID= @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
	FROM   Vehicle.VHChargeDetail  
	WHILE EXISTS
	(SELECT id
	FROM    Vehicle.VHChargeDetail  
	WHERE   VHChargeDetailID  = @VHChargeDetailID
	)
	BEGIN
			SELECT @VHChargeDetailID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
			FROM   Vehicle.VHChargeDetail  
			SET @i = @i + 1
	END
	
	
 SELECT @ModID=ModID  FROM General.Module WHERE ModName=@ModName  
  
    -- select *,VHChargeDetailID,EstateCodeL,VHWSCode,EstateCode,VHDetailCostCode,Type,ModID,LedgerType,LedgerNo,AYear,AMonth,Value,JDescp  from vehicle.vhchargedetail  
 INSERT INTO Vehicle.VHChargeDetail  
  (VHChargeDetailID,  
  EstateCodeL,   
  VHWSCode ,  
  EstateCode ,  
  VHDetailCostCode ,  
  Type,   
  ModID ,  
  LedgerType ,  
  LedgerNo ,  
  AYear ,  
  AMonth ,  
  Value ,  
  JDescp ,  
  CreatedBy,  
  CreatedOn,  
  ModifiedBy,  
  ModifiedOn,
  UOMID,
  QtyUsed,
  RefNo)  
 VALUES  
  (@VHChargeDetailID,  
  @EstateCodeL ,  
  @VHWSCode ,  
  @EstateCode ,  
  @VHDetailCostCode,   
  @Type ,  
  @ModID,   
  @LedgerType ,  
  @LedgerNo ,  
  @AYear ,  
  @AMonth ,   
  @Value ,  
  @JDescp ,  
  @CreatedBy,  
  @Createdon,  
  @ModifiedBy,  
  @ModifiedOn,  
  @UOMID,
  @QtyUsed,
  @RefNo);  
  
 --SELECT @ConcurrencyId = ConcurrencyId FROM Accounts.JournalDetail WHERE JournalDetID=@JournalDetID;  
END  
  
-- RETURN SCOPE_IDENTITY();   
   
END TRY  
BEGIN CATCH  
 DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
      
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  
 RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
END CATCH;  










