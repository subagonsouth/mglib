; docformat = 'rst'

;= overload methods

pro mg_column::_overloadBracketsLeftSide, col, value, is_range, ss1
  compile_opt strictarr

  if (is_range[0]) then begin
    (*self.data)[ss1[0]:ss1[1]:ss1[2]] = value
  endif else begin
    (*self.data)[ss1] = value
  endelse
end


function mg_column::_overloadBracketsRightSide, is_range, ss1
  compile_opt strictarr

  if (is_range[0]) then begin
    result = (*self.data)[ss1[0]:ss1[1]:ss1[2]]
  endif else begin
    result = (*self.data)[ss1]
  endelse

  return, result
end


function mg_column::_overloadHelp, varname
  compile_opt strictarr

  _type = 'MG_COLUMN'
  _specs = string(n_elements(*self.data), format='(%"<%d rows>")')
  return, string(varname, _type, _specs, format='(%"%-15s %-9s = %s")')
end


function mg_column::_overloadImpliedPrint, varname
  compile_opt strictarr

  return, string(*self.data, /implied_print)
end


function mg_column::_overloadPrint
  compile_opt strictarr

  return, string(*self.data)
end


function mg_column::_overloadSize
  compile_opt strictarr

  return, size(*self.data, /dimensions)
end


;= property access methods

pro mg_column::setProperty, format=format
  compile_opt strictarr

  if (n_elements(format) gt 0L) then begin
    self.format = format
    ; TODO: set self.width as well
  endif
end


pro mg_column::getProperty, data=data, type=type, format=format, n_rows=n_rows, width=width
  compile_opt strictarr

  if (arg_present(data)) then data = *self.data
  if (arg_present(type)) then type = self.type
  if (arg_present(format)) then format = self.format
  if (arg_present(n_rows)) then n_rows = n_elements(*self.data)
  if (arg_present(width)) then width = self.width
end


;= lifecycle methods

pro mg_column::cleanup
  compile_opt strictarr

  ptr_free, self.data
end


function mg_column::init, data
  compile_opt strictarr

  self.data = ptr_new(data)
  self.type = size(data, /type)
  self.format = mg_default_format(self.type)
  self.width = mg_default_format(self.type, /width)

  return, 1
end


pro mg_column__define
  compile_opt strictarr

  !null = {mg_column, inherits IDL_Object, $
           type: 0L, $
           format: '', $
           width: 0L, $
           data: ptr_new()}
end


; main-level example program

c = mg_column(findgen(20))
help, c
c[0:4] = 2 * findgen(5)
print, c[3:6]

end
