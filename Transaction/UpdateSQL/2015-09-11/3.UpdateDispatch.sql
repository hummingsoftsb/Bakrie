USE [BSPMS_POM]
GO
/****** Object:  StoredProcedure [Production].[CPODispatchUpdate]    Script Date: 11/9/2015 9:52:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Production].[CPODispatchUpdate]
	-- Add the parameters for the stored procedure here
		   @DispatchID nvarchar(50),
		   @EstateID nvarchar(50),
		   @ProductID nvarchar(50),
           @ActiveMonthYearID nvarchar(50),
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
           @ModifiedBy nvarchar(50),
           @ModifiedOn datetime,
		   @isKernel varchar(50) = null,
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

Declare @BFQty float, @MillWeightOld float

	select @MillWeightOld = CPODispatch.MillWeight from Production.CPODispatch WHERE  DispatchID  =@DispatchID 		AND EstateID =@EstateID 		AND ActiveMonthYearID =@ActiveMonthYearID    
		UPDATE Production.CPODispatch   SET 
	       DispatchDate  =@DispatchDate 
           ,BAPNo  =@BAPNo  
           ,DOA  =@DOA  
           ,DOATime  =@DOATime  
           ,DOL  =@DOL  
           ,DOLTime  =@DOLTime   
           ,DCL  =@DCL  
           ,DCLTime  =@DCLTime 
           ,ShipPontoon  =@ShipPontoon
           ,DepartureDate =@DepartureDate 
           ,DepartureTime =@DepartureTime 
           ,MillWeight =@MillWeight 
           ,LoadingLocationID =@LoadingLocationID  
           ,ModifiedBy=@ModifiedBy
           ,ModifiedOn =GETDATE()
		   ,BuyerName = @BuyerName,
			KontrakNo= @KontrakNo,
			NoPenyerahan = @NoPenyerahan,
			NoInstruksi=@NoInstruksi,
			JumlahKontrak=@JumlahKontrak,
			NoSim= @NoSim,
			NoTruk=@NoTruk,
			SealNo=@SealNo,
			DriverName=@DriverName  ,
			TransporterNo=@TransporterNo ,
			SPBNo=@SPBNo,
			TermofSales=@TermofSales
		
		WHERE  DispatchID  =@DispatchID 
		AND EstateID =@EstateID 
		AND ActiveMonthYearID =@ActiveMonthYearID   ;
						

		if @isKernel = '1'
		begin 
			select @BFQty = Production.KernelStorage.BFQty from Production.KernelStorage where Production.KernelStorage.Code = @LoadingLocationID	
			if @BFQty <> 0
			 begin
				Update Production.KernelStorage set Production.KernelStorage.BFQty = (Production.KernelStorage.BFQty + @MillWeightOld) - @MillWeight where Production.KernelStorage.Code = @LoadingLocationID
			 end
		end
		else
		begin
			select @BFQty = Production.TankMaster.BFQty from Production.TankMaster where Production.TankMaster.TankNo = @LoadingLocationID		
			 if @BFQty <> 0
			 begin
				Update Production.TankMaster set Production.TankMaster.BFQty = (Production.TankMaster.BFQty + @MillWeightOld) - @MillWeight where Production.TankMaster.TankNo = @LoadingLocationID
			 end
		end
		
		
END TRY
BEGIN CATCH
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END CATCH;
























