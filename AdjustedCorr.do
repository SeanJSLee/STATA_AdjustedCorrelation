* Adjusting correaltion with coeff and its Standad Error;SE
* Program written by Jaeseok "Sean" Lee ; SEP/27/20
* Base code by "Umut Ozek"

* input variable must be ordered.
* variable 1, 1's SE, variable 2, 2's SE

cap program drop adjed_corr
program define adjed_corr , rclass
	* I use STATA 15.1, Backward compartible not tested.
	* If your version is less than 15.1, change below parameter
  * ssc install ci2 requried.
  version 15.1
  syntax varlist(min=4 max=4) [if] [aw]
	tokenize `varlist'
	di "Var list: `1' , `2' ,  `3' ,  `4'"
	di "corr `1' `3'"
	corr `1' `3' `if' [`weight' `exp']
	return scalar unadj_corr = `r(rho)'
	di "Result: unadjusted saved in r(unadj_corr)=`r(rho)'"
	***** for adjusted corr ****
	*cap drop t_*
	tempvar t_rvar_err_1 t_rvar_err_2 t_var_1 t_var_2 t_rel_1 t_rel_2 t_rho_Ppmc t_rho_adj
	egen `t_rvar_err_1' = mean(`2'^2)
	egen `t_rvar_err_2' = mean(`4'^2)
	qui su `1'
	gen `t_var_1' = r(Var)
	qui su `3'
	gen `t_var_2' = r(Var)
	gen  `t_rel_1' = `t_var_1' / (`t_var_1' + `t_rvar_err_1')
	gen  `t_rel_2' = `t_var_2' / (`t_var_2' + `t_rvar_err_2')
	su t_*
  ci2  `1' `3' `if' [`weight' `exp'] , corr
  gen  `t_rho_Ppmc' = `r(rho)'
  gen  `t_rho_adj'   = `t_rho_Ppmc' / ((`t_rel_1' * `t_rel_2')^0.5)
  qui su `t_rho_adj'
  di "The Pearson product moment correlation: `r(mean)'"
  if (`r(mean)' >  1) {
		return scalar adj_corr = 1
		di "Result: unadjusted saved in r(adj_corr)=1"
	}
  else {
		return scalar adj_corr = `r(mean)'
		di "Result: unadjusted saved in r(adj_corr)=`r(mean)'"
	}
end
