#include "header.h"
#include "stubs.h"
#include "CuTest.h"

/* Including function under test */
#include "inodes.m"
#include "modes.m"
#include "astrings.m"
#include "compressor.m"
#include "compressible_object.m"
#include "hash_object.m"
#include "bytetable.m"
#include "region.m"

/****** Test Code ******/

struct axfs_config acfg;
struct axfs_objects aobj;

static void Inodes_createdestroy(CuTest *tc)
{
	Inodes *inodes;
	int output;
	printf("Running %s\n", __FUNCTION__);
	acfg.input = "./tovtf";
	acfg.max_nodes = 100;
	acfg.block_size = 16*1024;
	acfg.page_size = 4096;
	acfg.compression = "lzo";
	acfg.max_text_size = 10000;
	acfg.max_number_files = 100000;

	if(system("ruby src/unittests.rb clean"))
		return -1;
	if(system("ruby src/unittests.rb createdestroy"))
		return -1;

	inodes = [[Inodes alloc] init];
	[inodes free];
	[inodes release];

	output = 0;
	CuAssertIntEquals(tc, 0, output);
}

static void Inodes_devnode(CuTest *tc)
{
	Inodes *inodes;
	struct inode_struct *inode;

	printf("Running %s\n", __FUNCTION__);
	acfg.input = "./tovtf";
	acfg.max_nodes = 100;
	acfg.block_size = 16*1024;
	acfg.page_size = 4096;
	acfg.compression = "lzo";
	acfg.max_text_size = 10000;
	acfg.max_number_files = 100000;


	if(system("ruby src/unittests.rb clean"))
		return -1;
	if(system("ruby src/unittests.rb node"))
		return -1;

	inodes = [[Inodes alloc] init];

	NSString *path = @"./tovtf/node1";

	inode = (struct inode_struct *) [inodes addInode: path];

	CuAssertIntEquals(tc, 5, major(inode->size));
	CuAssertIntEquals(tc, 7, minor(inode->size));

	[inodes free];
	[inodes release];
	system("ruby src/unittests.rb clean");
}

/*
void print_data(void *d, uint64_t l)
{
	int i;
	uint8_t *c = d;

	for(i=0;i<l;i++) {
		printf("%02x",c[i]);
	}
	printf("\n");
}
*/

/****** End Test Code ******/

static CuSuite* GetSuite(void){
	CuSuite* suite = CuSuiteNew();

	SUITE_ADD_TEST(suite, Inodes_createdestroy);
	SUITE_ADD_TEST(suite, Inodes_devnode);
//	SUITE_ADD_TEST(suite, );
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
