
/****** Object:  StoredProcedure [Checkroll].[DailyReceiptionWithTeamInsert]    Script Date: 26/10/2015 9:49:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Checkroll].[DailyReceiptionWithTeamInsert]
	-- Add the parameters for the stored procedure here
	@DailyReceiptionID nvarchar(50),
	@DailyReceiptionWithTeamID nvarchar(50),
	@EstateID nvarchar(50),
	@EstateCode nvarchar(50),
	@OTHours numeric(18,2),
	@FKPSerialNo VARCHAR(15),
	--@StationID nvarchar(50), 
	@DivID nvarchar(50),
	@YOPID nvarchar(50),
	@BlockID nvarchar(50),
	@IsDrivePremi char(1),
	@Tonnage numeric(18,3),
	@PremiValue numeric(18,2),
	--@NActualBunches numeric(18,0),
	--@NPayedBunches numeric(18,0),
	--@NLooseFruits numeric(18,3),
	--@BActualBunches numeric(18,0),
	--@BPayedBunches numeric(18,0),
	--@BLooseFruits numeric(18,3),
	@TphNormal nvarchar(50),
	@UnripeNormal numeric(8, 0) ,
	@UnderRipeNormal numeric(8, 0),
	@OverRipeNormal numeric(8, 0),
	@RipeNormal numeric(8, 0),
	@LooseFruitNormal numeric(8, 2),
	@DiscardedNormal numeric(8,0),
	@HarvestedNormal numeric(8, 0),
	@DeductedNormal numeric(8, 0),
	@PaidNormal numeric(8, 0),
	@TphBorongan nvarchar(50) ,
	@UnripeBorongan numeric(8, 0),
	@UnderRipeBorongan numeric(8, 0),
	@OverRipeBorongan numeric(8, 0),
	@RipeBorongan numeric(8, 0),
	@LooseFruitBorongan numeric(8, 2),
	@DiscardedBorongan numeric(8,0),
	@HarvestedBorongan numeric(8, 0),
	@DeductedBorongan numeric(8, 0),
	@PaidBorongan numeric(8, 0),
	@Ha numeric(18, 3),
	@CreatedBy nvarchar(50),
	@CreatedOn datetime,
	@ModifiedBy nvarchar(50),
	@ModifiedOn datetime,
	@PremiHK numeric(18,2),
	@BlkHK numeric(18,2),
	@DeductionLainNormal numeric(8,3),
	@DeductionLainBorongan numeric(8,3),
	@DailyReceiptionDetID nvarchar(50) output
AS

	
BEGIN TRY
    -- Get New Primary key
  
	Declare @count int
	--Declare @DailyReceiptionDetID nvarchar(50)
	Declare	@ConcurrencyId rowversion
  
--    SELECT @DailyReceiptionDetID =  @EstateCode+'R'+  CAST((CASE WHEN (ISNULL(MAX(Id), -1) = -1) THEN 1 WHEN MAX(Id) >= 1 THEN MAX(Id) + 1 END) AS VARCHAR) 
--FROM Checkroll.DailyReceiption;
 
 
  SELECT @DailyReceiptionDetID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
            FROM   Checkroll.DailyReceiption
            DECLARE @i INT = 2
            WHILE EXISTS
            (SELECT id
            FROM    Checkroll.DailyReceiption
            WHERE   DailyReceiptionDetID = @DailyReceiptionDetID
            )
            BEGIN
                    SELECT @DailyReceiptionDetID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                    FROM   Checkroll.DailyReceiption
                    SET @i = @i + 1
            END
            BEGIN
                    SELECT @DailyReceiptionWithTeamID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                    FROM   Checkroll.DailyReceptionWithTeam
                    SET @i = @i + 1
            END
    
    -- Insert statements for procedure here
	INSERT INTO Checkroll.DailyReceiption
		(
		DailyReceiptionDetID,
		DailyReceiptionID,
	    EstateID,
	    OTHours,
	    --StationID,		
		DivID,
		YOPID,
		BlockID,
		IsDrivePremi,
		Tonnage,
		--NActualBunches,
		--NPayedBunches,
		--NLooseFruits,
		--BActualBunches,
		--BPayedBunches,
		--BLooseFruits,
		PremiValue, 
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn,
		PremiHK ,
		BlkHK)
	VALUES
		(
		@DailyReceiptionDetID,
		@DailyReceiptionID,
	    @EstateID,
		@OTHours,
		--@StationID,
		@DivID,
		@YOPID,
		@BlockID,
		@IsDrivePremi,
		@Tonnage,
		--@NActualBunches,
		--@NPayedBunches,
		--@NLooseFruits,
		--@BActualBunches,
		--@BPayedBunches,
		--@BLooseFruits,
		@PremiValue, 
		@CreatedBy,
		@CreatedOn,
		@ModifiedBy,
		@ModifiedOn,
		@PremiHK ,
		@BlkHK);
		
	
		INSERT INTO Checkroll.DailyReceptionWithTeam
		(
		DailyReceiptionWithTeamID,
		DailyReceiptionDetID,
		FKPSerialNo,
		TphNormal ,
		UnripeNormal  ,
		UnderRipeNormal ,
		OverRipeNormal,
		RipeNormal ,
		LooseFruitNormal ,
		DiscardedNormal,
		HarvestedNormal ,
		DeductedNormal ,
		PaidNormal ,
		TphBorongan  ,
		UnripeBorongan ,
		UnderRipeBorongan,
		OverRipeBorongan ,
		RipeBorongan ,
		LooseFruitBorongan,
		DiscardedBorongan,
		HarvestedBorongan,
		DeductedBorongan ,
		PaidBorongan,
		Ha,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn,
		DeductionLainNormal,
		DeductionLainBorongan)
	VALUES
		(
		@DailyReceiptionWithTeamID,
		@DailyReceiptionDetID,
		@FKPSerialNo,
		@TphNormal ,
		@UnripeNormal  ,
		@UnderRipeNormal ,
		@OverRipeNormal,
		@RipeNormal ,
		@LooseFruitNormal ,
		@DiscardedNormal,
		@HarvestedNormal ,
		@DeductedNormal ,
		@PaidNormal ,
		@TphBorongan  ,
		@UnripeBorongan ,
		@UnderRipeBorongan,
		@OverRipeBorongan ,
		@RipeBorongan ,
		@LooseFruitBorongan,
		@DiscardedBorongan,
		@HarvestedBorongan,
		@DeductedBorongan ,
		@PaidBorongan,
		@Ha,
		@CreatedBy,
		@CreatedOn,
		@ModifiedBy,
		@ModifiedOn,
		@DeductionLainNormal,
		@DeductionLainBorongan
		);
		

	--SELECT @ConcurrencyId = ConcurrencyId FROM Checkroll.DailyReceiption 
	--WHERE DailyReceiptionDetID=@DailyReceiptionID;

	--RETURN SCOPE_IDENTITY();	
	
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


