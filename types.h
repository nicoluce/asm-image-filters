#ifndef TYPES_H_
#define TYPES_H_

#include "external/libbmp.h"

typedef struct filter_config_t
{
  char *filter_name;
  bmp_img src, src_2, dst;
  void *extra_config;

  char *input_file;
  char *input_file_2;
  char  output_file[255];
  char *output_folder;
  char *extra_output_file;
  int interation_amount;
} filter_config_t;

typedef void (params_parser_fn_t) (int, char *[], filter_config_t *);
typedef void (aplicator_fn_t) (filter_config_t*);

typedef struct filter_t {
  char *name;
  params_parser_fn_t   *params_parser;
  // mostrador_ayuda_fn_t *ayuda;
  aplicator_fn_t       *aplicator;
  // int					 n_entradas;
} filter_t;


#define DECLARE_FILTER(name) params_parser_fn_t params_parser_##name; \
                             aplicator_fn_t apply_##name;
#define DEFINE_FILTER(name) {#name, params_parser_##name, apply_##name}


#endif  // TYPES_H_
