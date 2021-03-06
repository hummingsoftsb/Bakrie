USE [BSPMS_POM]
GO
/****** Object:  StoredProcedure [Production].[KernalProductionStockInsert]    Script Date: 12/6/2015 11:40:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--KERNAL PRODUCTION

ALTER PROCEDURE [Production].[KernalProductionStockInsert]
 
		 --  @GradingID nvarchar(50) output,
           @EstateID nvarchar(50),
           @EstateCode nvarchar(50),
       
           @StockTankID nvarchar(50),
           @StockKernalID nvarchar(50),
           @ProductionID nvarchar(50),
           --@TransTankID nvarchar(50),
           -- @LoadTankID nvarchar(50),
            @Capacity  numeric(18,3)
           ,@BalanceBF  numeric(18,3)
           ,@CurrentReading  numeric(18,3)
           ,@Writeoff numeric(18,3)
           ,@Reason nvarchar(150)
           ,@Measurement  numeric(18,2)
           ,@Temp  numeric(18,2)
           ,@FFAP  numeric(18,2)
           ,@MoistureP numeric(18,2)  
           ,@DirtP numeric(18,3),   
           --@LoadingLocationID nvarchar(50), 
           --@TransLocationID nvarchar(50),
           @ActiveMonthYearID nvarchar(50),
           --@CropYieldID nvarchar(50),
           --@CPOProductionDate Datetime,
           --@QtyToday numeric(18,3),
           --@QtyMonthToDate numeric(18,3),
           --@QtyYearTodate numeric(18,3),
           --@TransQty  numeric(18,3),
           --@TransMonthToDate numeric(18,3),  
           --@LoadQty  numeric(18,3),
           --@LoadMonthToDate numeric(18,3), 
           @CreatedBy nvarchar(50),
           @CreatedOn datetime,
           @ModifiedBy nvarchar(50),
           @ModifiedOn datetime
 

AS
--INSERT FOR PRODUCT STOCK CPO-----

BEGIN 

    -- Get New Primary key
    
  --  Declare @countStock int;
    Declare @ProdStockID nvarchar(50);


          -- Get New Primary key
                SELECT @ProdStockID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
                FROM   Production.CPOProductionStockCPO
                DECLARE @i INT = 2
                WHILE EXISTS
                (SELECT id
                FROM    Production.CPOProductionStockCPO
                WHERE   ProdStockID = @ProdStockID
                )
                BEGIN
                        SELECT @ProdStockID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                        FROM  Production.CPOProductionStockCPO
                        SET @i = @i + 1
                END
    

    
 INSERT INTO Production.CPOProductionStockCPO    
			([ProdStockID] 
			,[EstateID]
			,[ActiveMonthYearID]
           ,[ProductionID]
           ,[TankID]
           ,[KernelStorageID] 
           ,[Capacity] 
           ,[PrevDayReading]  
           ,[CurrentReading]
           ,[Writeoff]
           ,[Reason]
           ,[Measurement]  
           ,[Temp]   
           ,[FFAP]   
           ,[MoistureP]   
           ,[DirtP]    
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn])
   
     Values
			(
			@ProdStockID
           ,@EstateID
           ,@ActiveMonthYearID
           ,@ProductionID
           ,@StockTankID 
           ,@StockKernalID 
           ,@Capacity  
           ,@BalanceBF  
           ,@CurrentReading
           ,@Writeoff
           ,@Reason  
           ,@Measurement 
           ,@Temp 
           ,@FFAP 
           ,@MoistureP 
           ,@DirtP 
           ,@CreatedBy
           ,GETDATE ()
           ,@ModifiedBy
           ,GETDATE () );
 --select 1
	
UPDATE Production.KernelStorage SET BFQty = @CurrentReading  WHERE KernelStorageID = @StockKernalID;	
END 


BEGIN
SELECT ProdStockID  FROM Production.CPOProductionStockCPO   WHERE  ProdStockID=@ProdStockID;  
END
