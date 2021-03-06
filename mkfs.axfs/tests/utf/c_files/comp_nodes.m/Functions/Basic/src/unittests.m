#include "header.h"
#include "stubs.h"
#include "CuTest.h"

/* Including function under test */
#include "hash_object.m"
#include "bytetable.m"
#include "compressible_object.m"
#include "pages.m"
#include "compressor.m"
#include "c_blocks.m"
#include "region.m"
#include "comp_nodes.m"
#include "nodes_object.m"


/****** Test Code ******/

struct axfs_config acfg;

static void CompNodes_createdestroy(CuTest *tc)
{
	CompNodes *nodes;
	int output;
	printf("Running %s\n", __FUNCTION__);
	acfg.max_nodes = 100;
	acfg.block_size = 16*1024;
	acfg.page_size = 4096;
	acfg.compression = "lzo";

	nodes = [[CompNodes alloc] init];
	[nodes free];
	[nodes release];

	output = 0;
	CuAssertIntEquals(tc, 0, output);
}


static void CompNodes_compressed_little(CuTest *tc)
{
	CompNodes *nodes;
	Pages *pages;
	uint64_t l = 4 * 1024;
	uint8_t *data0;
	uint8_t *data1;
	uint8_t *data2;
	uint8_t *data3;
	uint8_t *data4;
	void *output[5];
	uint64_t length;
	uint64_t size;
	void *data;

	printf("Running %s\n", __FUNCTION__);
	acfg.max_nodes = 6000;
	acfg.block_size = 16*1024;
	acfg.page_size = 4096;
	acfg.compression = "lzo";

	nodes = [[CompNodes alloc] init];

	pages = [[Pages alloc] init];

	data0 = malloc(l);
	memset(data0,5,l);
	output[0] = [pages addPage: data0 length: l];

	data1 = malloc(l);
	memset(data1,6,l);
	output[1] = [pages addPage: data1 length: l];

	data2 = malloc(l);
	memset(data2,7,l);
	output[2] = [pages addPage: data2 length: l];

	data3 = malloc(l);
	memset(data3,4,l);
	output[3] = [pages addPage: data3 length: 4000];

	data4 = malloc(l);
	memset(data4,5,l);
	output[4] = [pages addPage: data4 length: 500];

	[nodes addPage: output[0]];
	[nodes addPage: output[1]];
	[nodes addPage: output[2]];
	[nodes addPage: output[3]];
	[nodes addPage: output[4]];

	length = [nodes length];
	size = [nodes size];
	CuAssertIntEquals(tc, 5, length);
	data = [nodes data];

	CuAssertTrue(tc, 4096*5 > size);
	CuAssertTrue(tc, 0 < size);
	CuAssertTrue(tc, data != 0);

	[nodes free];
	[nodes release];

	[pages free];
	[pages release];
}

/****** End Test Code ******/

static CuSuite* GetSuite(void){
	CuSuite* suite = CuSuiteNew();

	SUITE_ADD_TEST(suite, CompNodes_createdestroy);
	SUITE_ADD_TEST(suite, CompNodes_compressed_little);
//	SUITE_ADD_TEST(suite, Nodes_compressed_big);
	return suite;
}

void FreeSuite(CuSuite* suite)
{
	int i;
	for (i = 0 ; i < suite->count ; ++i)
	{
		if(suite->list[i] != NULL) {
			free((void*)suite->list[i]->name);
			free(suite->list[i]);
		} else
			suite->list[i] = 0;
	}
	free(suite);
}

void RunAllTests(void)
{
	CuString *output = CuStringNew();
	CuSuite* suite = CuSuiteNew();
	CuSuite* newsuite = GetSuite();
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	CuSuiteAddSuite(suite, newsuite);
	CuSuiteRun(suite);

	CuSuiteSummary(suite, output);
	CuSuiteDetails(suite, output);
	printf("%s\n", output->buffer);
	FreeSuite(suite);
	free(newsuite);
	free(output->buffer);
	free(output);
	[pool drain];

	return;
}
