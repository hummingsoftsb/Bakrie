
GO
/****** Object:  StoredProcedure [Production].[CPODispatchInsert]    Script Date: 14/9/2015 2:16:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Production].[CPODispatchInsert]
 
		 --  @DispatchID nvarchar(50) output,
           @EstateID nvarchar(50),
           @EstateCode nvarchar(50),
           @ActiveMonthYearID nvarchar(50),
           @ProductID nvarchar(50),
           @DispatchDate date,
           @BAPNo nvarchar(50),
           @ShipPontoon nvarchar(80),
           @DOA Date,
           @DOATime Time(7),
           @DOL Date,
           @DOLTime Time(7),
           @DCL Date,
           @DCLTime Time(7),
           @DepartureDate Date,
           @DepartureTime time(7),
           @MillWeight numeric (18,3),
           @LoadingLocationID  nvarchar(50),
           @CreatedBy nvarchar(50),
           @CreatedOn datetime,
           @ModifiedBy nvarchar(50),
           @ModifiedOn datetime,
		   @isKernel varchar(50) = NULL,
		   @BuyerName nvarchar(50),
		   @KontrakNo nvarchar(50),
		   @NoPenyerahan nvarchar(50),
			@NoInstruksi nvarchar(50),
			@JumlahKontrak numeric(18, 4),
			@NoSim nvarchar(50),
			@NoTruk nvarchar(50),
			@SealNo nvarchar(50),
			@DriverName nvarchar(50),
			@TransporterNo nvarchar(50),
			@SPBNo nvarchar(50),
			@TermofSales nvarchar(50)
 

AS
 
BEGIN TRY

    -- Get New Primary key
        Declare @DispatchID nvarchar(50)
		Declare @BFQty float
     BEGIN
                DECLARE @i INT = 2
                        SELECT @DispatchID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
                        FROM   Production.CPODispatch 
                        WHILE EXISTS
                        (SELECT id
                        FROM    Production.CPODispatch 
                        WHERE   DispatchID  = @DispatchID
                        )
                        BEGIN
                                SELECT @DispatchID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                                FROM   Production.CPODispatch 
                                SET @i = @i + 1
				END
     

   
    
     
 INSERT INTO Production.CPODispatch  
			([DispatchID]
           ,[EstateID]
           ,[ActiveMonthYearID]
           ,[ProductID]
           ,[DispatchDate]
           ,[BAPNo]
           ,[ShipPontoon]
           ,[DOA]
           ,[DOATime]
           ,[DOL]
           ,[DOLTime]
           ,[DCL] 
           ,[DCLTime] 
           ,[DepartureDate] 
           ,[DepartureTime] 
           ,[MillWeight] 
           ,[LoadingLocationID] 
           ,[CreatedBy]
           ,[CreatedOn]
           ,[ModifiedBy]
           ,[ModifiedOn]
		   ,[BuyerName]
		  ,[KontrakNo]
		  ,[NoPenyerahan]
		  ,[NoInstruksi]
		  ,[JumlahKontrak]
		  ,[NoSim]
		  ,[NoTruk]
		  ,[SealNo]
		  ,[DriverName]
		  ,[TransporterNo]
		  ,[SPBNo]
		  ,[TermofSales])
     
     Values
			(@DispatchID
           ,@EstateID
           ,@ActiveMonthYearID
           ,@ProductID
           ,@DispatchDate
           ,@BAPNo
           ,@ShipPontoon
           ,@DOA
           ,@DOATime
           ,@DOL
           ,@DOLTime
           ,@DCL 
           ,@DCLTime 
           ,@DepartureDate 
           ,@DepartureTime 
           ,@MillWeight 
           ,@LoadingLocationID 
           ,@CreatedBy
           ,GETDATE ()
           ,@ModifiedBy
           ,GETDATE ()
           ,@BuyerName
		  ,@KontrakNo
		  ,@NoPenyerahan
		  ,@NoInstruksi
		  ,@JumlahKontrak
		  ,@NoSim
		  ,@NoTruk
		  ,@SealNo
		  ,@DriverName
		  ,@TransporterNo
		  ,@SPBNo
		  ,@TermofSales);
       
if @isKernel = '1'
	Begin
		select @BFQty = Production.KernelStorage.BFQty from Production.KernelStorage where Production.KernelStorage.Code = @LoadingLocationID
		if @BFQty <> 0
			Update Production.KernelStorage set Production.KernelStorage.BFQty = Production.KernelStorage.BFQty - @MillWeight where Production.KernelStorage.Code = @LoadingLocationID
	end
else
	Begin
		 select @BFQty = Production.TankMaster.BFQty from Production.TankMaster where Production.TankMaster.TankNo = @LoadingLocationID
		 if @BFQty <> 0
			Update Production.TankMaster set Production.TankMaster.BFQty = Production.TankMaster.BFQty - @MillWeight where Production.TankMaster.TankNo = @LoadingLocationID
	END	     
 SELECT DispatchID  FROM Production .CPODispatch  WHERE DispatchID = @DispatchID 



 END
		
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























