import React from 'react'
import { TestStatus, Test } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup } from './TestsGroup'

export function TestsGroupList({ tests }: { tests: Test[] }): JSX.Element {
  const testsWithIndex = tests.map((test, i) => ({ index: i + 1, ...test }))
  const passed = testsWithIndex.filter(
    (test) => test.status === TestStatus.PASS
  )
  const failed = testsWithIndex.filter(
    (test) =>
      test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
  )
  const firstFailedTest = failed.slice(0, 1)
  const skipped = testsWithIndex.filter(
    (test) => !passed.concat(firstFailedTest).includes(test)
  )

  return (
    <div className="tests-list">
      <TestsGroup tests={passed}>
        <TestsGroup.Header>
          <GraphicalIcon icon="passed-check-circle" className="indicator" />
          <TestsGroup.Title status="passed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <TestsGroup.Tests />
      </TestsGroup>
      <TestsGroup open={true} tests={firstFailedTest}>
        <TestsGroup.Header>
          <GraphicalIcon icon="failed-check-circle" className="indicator" />
          <TestsGroup.Title status="failed" />
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </TestsGroup.Header>
        <TestsGroup.Tests />
      </TestsGroup>
      <TestsGroup tests={skipped}>
        <TestsGroup.Header>
          <GraphicalIcon icon="skipped-check-circle" className="indicator" />
          <TestsGroup.Title status="skipped" />
        </TestsGroup.Header>
      </TestsGroup>
    </div>
  )
}
