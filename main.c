#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "external/libbmp.h"
#include "types.h"

const char *basename(const char *path)
{
    const char *res = strrchr(path, '/');
    if (res != NULL) {
        return res + 1;
    }
    return path;
}

DECLARE_FILTER(cropflip)
DECLARE_FILTER(sepia)

filter_t filters[] = {
  DEFINE_FILTER(cropflip),
  DEFINE_FILTER(sepia)
};

void ProcessOptions(int argc, char const *argv[], filter_config_t* config)
{
  config->filter_name = argv[2];
  config->interation_amount = 1;
  config->input_file = argv[1];
  config->output_folder = ".";
  config->extra_output_file = "";

}

filter_t* GetFilter(filter_config_t* config)
{
  for (int i = 0; filters[i].name != 0; i++) {
    if (strcmp(config->filter_name, filters[i].name) == 0)
      return &filters[i];
  }

  fprintf(stderr, "Unknown filter\n");
  return NULL;
}

void RunFilter(filter_config_t* config, aplicator_fn_t* applicator)
{
  snprintf(config->output_file, sizeof  (config->output_file),
           "%s/%s.%s.bmp", config->output_folder,
           basename(config->input_file), config->filter_name);

  printf("%s\n", basename(config->output_file));

  if (BMP_OK != bmp_img_read(&config->src, config->input_file)) {
    printf("Unable to open file: %s\n", config->input_file);
    return;
  }

  for (int i = 0; i < config->interation_amount; i++) {
    applicator(config);
  }

  bmp_img_free(&config->src);
  if (BMP_OK != bmp_img_write(&config->dst, config->output_file)) {
    printf("Unable to write on file: %s\n", config->output_file);
    return;
  }
}

int main(int argc, const char** argv)
{
  filter_config_t config;
  ProcessOptions(argc, argv, &config);
  filter_t *filter = GetFilter(&config);

  if (filter != NULL) {
    filter->params_parser(argc, argv, &config);
    RunFilter(&config, filter->aplicator);
  }

  return 0;
}

