@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Store Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_StoreVH
  as select from zexp_config
{
      @Search.defaultSearchElement: true
  key config_key   as StoreId,
      config_value as StoreName,
      addl_field1  as City,
      addl_field2  as Region,
      addl_field3  as CostCenter,

      @Semantics.amount.currencyCode: 'Currency'
      budget_amt   as BudgetAmt,
      currency     as Currency
}
where
  config_type = 'STORE'
  and is_active = 'X'
