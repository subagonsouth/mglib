; docformat = 'rst'

;+
; binary classifier
; http://www.jeannicholashould.com/what-i-learned-implementing-a-classifier-from-scratch.html
;-

;= API

;+
; Use training set of data `x` and targets `y` to train the model.
;
; :Params:
;   x : in, required, type="fltarr(n_features, n_samples)"
;     data to learn on
;   y : in, required, type=fltarr(n_samples)
;     results for `x` data
;-
pro mg_perceptron::fit, x, y
  compile_opt strictarr

  dims = size(x, /dimensions)
  n_features = dims[0]
  n_samples = dims[1]

  *self.weights = fltarr(n_features + 1)
  *self.errors = lonarr(self.max_iterations)

  for i = 0L, self.max_iterations - 1L do begin
    errors = 0L
    for s = 0L, n_samples - 1L do begin
      xi = reform(x[*, s], n_features, 1)
      update = self.learning_rate * ((y[s])[0] - self->predict(xi))
      (*self.weights)[1:*] += update * xi
      (*self.weights)[0]   += update
      errors += long(update ne 0.0)
    endfor
    (*self.errors)[i] = errors
  endfor
end


;+
; Use previous training with `fit` method to predict targets for given data `x`.
;
; :Returns:
;   fltarr(n_samples)
;
; :Params:
;   x : in, required, type=fltarr(n_features, n_samples)
;     data to predict targets for
;   y : in, optional, type=fltarr(n_samples)
;     optional y-values; needed to get score
;
; :Keywords:
;   score : out, optional, type=float
;     set to a named variable to retrieve a score if `y` was specified
;-
function mg_perceptron::predict, x, y, score=score
  compile_opt strictarr

  y_predict = 2L * (reform((*self.weights)[1:*] # x) + (*self.weights)[0] ge 0.0) - 1L
  if (arg_present(score) && n_elements(y) gt 0) then begin
    score = total(y_predict eq y, /integer) / float(n_elements(y))
  endif
  return, y_predict
end


;= property access

pro mg_perceptron::getProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                _ref_extra=e
  compile_opt strictarr

  if (arg_present(max_iterations)) then max_iterations = self.max_iterations
  if (arg_present(learning_rate)) then learning_rate = self.learning_rate

  if (n_elements(e) gt 0L) then self->mg_estimator::getProperty, _extra=e
end


pro mg_perceptron::setProperty, max_iterations=max_iterations, $
                                learning_rate=learning_rate, $
                                _extra=e
  compile_opt strictarr

  if (n_elements(max_iterations) gt 0L) then self.max_iterations = max_iterations
  if (n_elements(learning_rate) gt 0L) then self.learning_rate = learning_rate
end


;= lifecycle methods

pro mg_perceptron::cleanup
  compile_opt strictarr

  ptr_free, self.weights, self.errors
  self->mg_estimator::cleanup
end


function mg_perceptron::init, max_iterations=max_iterations, $
                              learning_rate=learning_rate, $
                              _extra=e
  compile_opt strictarr

  if (~self->mg_estimator::init(_extra=e)) then return, 0

  self.type = 'binary classifier'

  self.weights = ptr_new(/allocate_heap)
  self.errors = ptr_new(/allocate_heap)

  _max_iterations = mg_default(max_iterations, 10L)
  _learning_rate = mg_default(learning_rate, 0.01)
  self->setProperty, max_iterations=_max_iterations, $
                     learning_rate=_learning_rate, $
                     _extra=e

  return, 1
end


pro mg_perceptron__define
  compile_opt strictarr

  !null = {mg_perceptron, inherits mg_estimator, $
           max_iterations: 0L, $
           learning_rate: 0.0, $
           weights: ptr_new(), $
           errors: ptr_new() $
          }
end


; main-level example program

iris = mg_load_iris()

; the first 100 samples have only two target values (categories)
data = iris.data[*, 0:99]
target = 2L * iris.target[0:99] - 1L  ; change to -1 and 1

seed = 0L
mg_train_test_split, data, target, $
                     x_train=x_train, y_train=y_train, $
                     x_test=x_test, y_test=y_test, $
                     test_size=0.1, $
                     seed=seed

p = mg_perceptron()
p->fit, x_train, y_train
y_results = p->predict(x_test, y_test, score=score)

for s = 0L, n_elements(y_test) - 1L do begin
  if (y_results[s] eq y_test[s]) then begin
    print, s, iris.target_names[y_results[s] eq 1], $
           format='(%"%3d: results match, both: %s")'
  endif else begin
    print, s, iris.target_names[y_results[s] eq 1], $
              iris.target_names[y_test[s] eq 1], $
              format='(%"%3d: incorrect result: %s, test standard: %s")'
  endelse
endfor

print, score * 100.0, format='(%"Prediction score: %0.1f\%")'

end