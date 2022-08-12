require "utils"

-- Some helper functions used to buy specific items from vendors

function GetFirstInput(panel)
	FindInput(panel)
	return FINDINPUT[1].ID
end

function GetFirstButton(panel, filter)
	FindButton(panel, filter)
	return FINDBUTTON[1].NAME
end

function CheckForLabel(panel, filter)
	FindLabel(panel, filter)
	if FINDLABEL ~= nil then
		return true
	else
		return false
	end
end

function BuyFromVendor(VendorName, Items, Amount)

	if type(Items) == "string" then
		Items = {Items}
	end

	-- Set buy amount to 9999 if all specified
	if Amount:lower() == "all" then
		Amount = 9999
	end

	-- Find the vendor
	FindMobile(VendorName)
	if FINDMOBILE == nil then
		return Log("Couldn't find vendor")
	end
	Vendor = FINDMOBILE[1]

	-- Move to the vendor
	Move(Vendor.ID)
	SafeSleep(1000)

	-- Open the buy menu
	ContextMenu(Vendor.ID, "Buy")
	SafeSleep(500)

	SomethingInStock = false

	-- Search for the item
	for i,Item in ipairs(Items) do
		BuyWindow = WaitForPanel("Buy")
		SearchInput = GetFirstInput(BuyWindow)
		SetInput(BuyWindow, SearchInput, Item)
		WaitForButtonThenClick(BuyWindow, "search")

		if CheckForLabel(BuyWindow, "Sold Out") then
			goto continue
		end

		SomethingInStock = true

			-- Buy one of the item
		FindButton(BuyWindow)
		WaitForButtonThenClick(BuyWindow, "AddToBill:")

		::continue::
	end

	if SomethingInStock then
		-- Set the amount
		WaitForButtonThenClick(BuyWindow, "Set All")
		AmountWindow = WaitForPanel("amount")
		AmountInput = GetFirstInput(AmountWindow)
		SetInput(AmountWindow, AmountInput, Amount)
		WaitForButtonThenClick(AmountWindow, "Enter")

		-- Click Accept
		WaitForButtonThenClick(BuyWindow, "Accept")
		AcceptButton = GetFirstButton(BuyWindow, "Accept")

		-- Confirm the sale
		ConfirmWindow = WaitForPanel("Confirm")
		WaitForButtonThenClick(ConfirmWindow, "pay")
	end

	ClosePanel(BuyWindow)

	Log("Buy process complete")

	if SomethingInStock then
		return true
	end

	return false

end



function SellToVendor(VendorName, Item, Amount)

	-- Set buy amount to 9999 if all specified
	if tostring(Amount):lower() == "all" then
		Amount = 9999
	end

	-- Find the vendor
	FindItem(VendorName)
	if FINDITEM == nil then
		return Log("Couldn't find vendor")
	end
	Vendor = FINDITEM[1]

	-- Move to the vendor
	Move(Vendor.ID)
	SafeSleep(1000)

	-- Open the buy menu
	ContextMenu(Vendor.ID, "Sell")
	SafeSleep(500)


	SellWindow = WaitForPanel("Sell")

		-- Buy one of the item
	-- FindButton(SellWindow, Item)
	print(Item)
	print(SellWindow)
	WaitForButton2ThenClick(SellWindow, Item)


	-- -- Set the amount
	-- WaitForButtonThenClick(SellWindow, "Set All")
	-- AmountWindow = WaitForPanel("amount")
	-- AmountInput = GetFirstInput(AmountWindow)
	-- SetInput(AmountWindow, AmountInput, Amount)
	-- WaitForButtonThenClick(AmountWindow, "Enter")

	-- -- Click Accept
	-- WaitForButtonThenClick(SellWindow, "Accept")
	-- AcceptButton = GetFirstButton(SellWindow, "Accept")

	-- -- Confirm the sale
	-- ConfirmWindow = WaitForPanel("Confirm")
	-- WaitForButtonThenClick(ConfirmWindow, "Confirm")

	-- ClosePanel(SellWindow)

	Log("Buy process complete")

end
