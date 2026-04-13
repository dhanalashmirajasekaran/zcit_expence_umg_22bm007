@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Header Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_ExpenseH
  provider contract transactional_query
  as projection on ZI_ExpenseH
{
  key ExpUuid,
      ExpId,

      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_StoreVH', element: 'StoreId' },
        additionalBinding: [
          { localElement: 'City',       element: 'City'       },
          { localElement: 'Region',     element: 'Region'     },
          { localElement: 'CostCenter', element: 'CostCenter' }
        ]
      }]
      StoreId,

      City,
      Region,
      CostCenter,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_VendorVH', element: 'VendorId' }
      }]
      VendorId,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_ExpCatVH', element: 'ExpCatId' }
      }]
      ExpCat,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_PayModeVH', element: 'PayModeId' }
      }]
      PayMode,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_GSTSlabVH', element: 'GSTCode' }
      }]
      GstSlab,

      @Semantics.amount.currencyCode: 'Currency'
      TotalAmt,

      @Semantics.amount.currencyCode: 'Currency'
      BaseAmt,

      @Semantics.amount.currencyCode: 'Currency'
      CgstAmt,

      @Semantics.amount.currencyCode: 'Currency'
      SgstAmt,

      Currency,
      Status,
      CreatedBy,
      CreatedOn,
      LocalLastChangedAt,

      /* Associations */
      _Items : redirected to composition child ZC_ExpenseI,
      _Store,
      _Vendor,
      _ExpCat,
      _PayMode
}
