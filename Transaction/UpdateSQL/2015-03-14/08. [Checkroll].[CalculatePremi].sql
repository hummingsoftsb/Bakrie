GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--===
-- Author : Chandra
-- Created On : 13-03-2015
-- Descp      :  DIgunakan untuk menghitung premi dari rubber
--
--===
create FUNCTION [Checkroll].[CalculatePremi] (
	@DateRubber datetime,	-- Tanggal Rubber
	@EmpId varchar(20), -- Emp ID
	@EstateCode varchar(10),		-- Estate Code
	@PersenProduct int,		-- 80% pengkali Product
	@ProductValue float,		-- nilai Product
	@ProductDrc float,		-- nilai drc	
	@ProductName varchar(20),		-- Product 
	@Status varchar(1) -- D = Dasar, P= Progressive , B = Bonus
	)
RETURNS money
AS
BEGIN
	declare @JumlahPenderes int
	declare @TotalKgPerHariPenderes float
	declare @JumlahHariPerBulan int
	declare @TotalBudget float,@PremiDasar money=0,@PremiProgresif money =0 ,@PremiBonus money =0  , @PremiMinggu money=0

	declare @BudgetPerHariProduct  float

	declare @ProduksiKeringProduct  float

	declare @PersenPremiProduct  float

	declare @RateProduct  float

	declare @monthId int
	declare @class varchar(1),@estateId varchar(5)
	declare @Min float,@max float, @rate float, @permiType varchar(20)

	select @monthId=Id from  Checkroll.GradeMonth where ZMonth= MONTH(@DateRubber) and ZYear= YEAR(@DateRubber)
	select @class=Class from  Checkroll.GradeMonthDetails where GradeMonthId=@monthId and EmpId=@EmpId
	


	select @JumlahHariPerBulan = dbo.CountDayInTheMonth(year(@DateRubber),month(@DateRubber))
	select @TotalBudget = TotalBudget from Checkroll.GradeMonth where ZYEAR=year(@DateRubber) and ZMonth=month(@DateRubber)
	select @estateId=EstateID from General.Estate WHERE EstateCode=@EstateCode
	select @JumlahPenderes =count(*) from Checkroll.CREmployee where WorkerType ='Penderes' and EstateID=@estateId
	set @TotalKgPerHariPenderes = convert(float,@TotalBudget) /  CONVERT(float,@JumlahHariPerBulan) / CONVERT(float,@JumlahPenderes)									
	
	set @BudgetPerHariProduct = @TotalKgPerHariPenderes * @PersenProduct /100
									--Tanya pa sai rumus nya seperti ini atau (@Product- (@Product * @DRC / 100)) <<- Dari chatting
			set @ProduksiKeringProduct =( @ProductValue * @ProductDrc / 100)
			set @PersenPremiProduct= @ProduksiKeringProduct / @BudgetPerHariProduct * 100
			DECLARE cProduct CURSOR local read_only FOR
			select Min,Max,Rate,PremiType from Checkroll.PremiSetupRubber where Class=@class and Product=@ProductName and EstateId=@estateId  and min < @PersenPremiProduct order by  min
			OPEN cProduct
			FETCH FROM cProduct INTO @min,@max,@rate,@permiType
			WHILE @@fetch_status = 0 
			BEGIN
				if(@permiType ='Dasar')					
				begin
					if(@PersenPremiProduct < @max)
						Set @PremiDasar =@PremiDasar+ (@ProduksiKeringProduct * @rate)
					else
						Set @PremiDasar =@PremiDasar+  (@BudgetPerHariProduct * @rate * @max/100)
				end
				else if(@permiType ='Progressive')					
				begin
					if(@PersenPremiProduct < @max)
						Set @PremiProgresif =@PremiProgresif+ (@ProduksiKeringProduct * @rate * (@PersenPremiProduct - @min) / 100)
					else
						Set @PremiProgresif =@PremiProgresif+ @BudgetPerHariProduct * @rate	* (@max-@min+1)/100
				end
				else if(@permiType ='Bonus')					
						Set @PremiBonus =@PremiBonus+ ((@ProduksiKeringProduct-@BudgetPerHariProduct) * @rate)					
				else if(@permiType ='Deres')					
						Set @PremiMinggu =@PremiMinggu+ ((@ProduksiKeringProduct) * @rate)					
				FETCH NEXT FROM cProduct INTO  @min,@max,@rate,@permiType
			END
			CLOSE cProduct
			DEALLOCATE cProduct
	if(@Status ='D')
		return @PremiDasar
	if(@Status ='P')
		return @PremiProgresif	
	if(@Status ='M')
		return @PremiMinggu
	return @PremiBonus
END;



